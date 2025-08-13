resource "databricks_instance_profile" "ip" {
  instance_profile_arn = aws_iam_instance_profile.dbx_ip.arn
}


# Secret scope for Redshift creds (so notebooks don't hardcode)
resource "databricks_secret_scope" "etl" { name = "${var.project}-${var.env}-secrets" }


resource "databricks_secret" "rs_user" {
  scope        = databricks_secret_scope.etl.name
  key          = "RS_USER"
  string_value = var.redshift_user
}
resource "databricks_secret" "rs_password" {
  scope        = databricks_secret_scope.etl.name
  key          = "RS_PASSWORD"
  string_value = var.redshift_password
}


# Upload notebooks from your repo to Workspace
# Expected files: 01_ingest_sales.py, 02_transform_sales.py, 03_load_to_redshift.py
resource "databricks_workspace_file" "nb_ingest" {
  source = "${var.dbx_notebooks_path}/01_ingest_sales.py"
  path   = "/Shared/${var.project}/${var.env}/01_ingest_sales.py"
}
resource "databricks_workspace_file" "nb_transform" {
  source = "${var.dbx_notebooks_path}/02_transform_sales.py"
  path   = "/Shared/${var.project}/${var.env}/02_transform_sales.py"
}
resource "databricks_workspace_file" "nb_load" {
  source = "${var.dbx_notebooks_path}/03_load_to_redshift.py"
  path   = "/Shared/${var.project}/${var.env}/03_load_to_redshift.py"
}


# A small job-cluster with Glue Catalog enabled
resource "databricks_job" "sales_batch" {
  name = "${var.project}-${var.env}-sales-batch"


  job_cluster {
    job_cluster_key = "c1"
    new_cluster {
      spark_version = var.dbx_spark_version
      node_type_id  = var.dbx_node_type
      num_workers   = var.dbx_num_workers


      aws_attributes { instance_profile_arn = aws_iam_instance_profile.dbx_ip.arn }


      spark_conf = {
        "spark.sql.catalogImplementation" = "hive"
        # Use AWS Glue Data Catalog as metastore
        "spark.hadoop.hive.metastore.client.factory.class" = "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
        "spark.hadoop.aws.region" = var.region
      }
    }
  }


  task {
    task_key        = "t1_ingest"
    description     = "Read raw CSV from S3 (raw) and register in Glue if needed"
    notebook_task { notebook_path = databricks_workspace_file.nb_ingest.path }
    job_cluster_key = "c1"
    libraries = []
  }


  task {
    task_key        = "t2_transform"
    description     = "Clean/aggregate and write curated parquet to S3 (curated)"
    notebook_task { notebook_path = databricks_workspace_file.nb_transform.path }
    job_cluster_key = "c1"
    depends_on { task_key = "t1_ingest" }
  }


  task {
    task_key        = "t3_load_redshift"
    description     = "COPY parquet from S3 (stage) into Redshift"
    notebook_task {
      notebook_path = databricks_workspace_file.nb_load.path
      base_parameters = {
        RS_ENDPOINT      = aws_redshift_cluster.this.endpoint
        RS_DB            = aws_redshift_cluster.this.database_name
        RS_IAM_ROLE_ARN  = aws_iam_role.redshift_copy.arn
        RAW_BUCKET       = aws_s3_bucket.raw.bucket
        CURATED_BUCKET   = aws_s3_bucket.curated.bucket
        STAGE_BUCKET     = aws_s3_bucket.stage.bucket
        GLUE_DB          = aws_glue_catalog_database.this.name
        SECRET_SCOPE     = databricks_secret_scope.etl.name
      }
    }
    job_cluster_key = "c1"
    depends_on { task_key = "t2_transform" }
  }
}


module "data_lake_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.data_bucket_name
  tags        = var.tags
}

module "iam" {
  source           = "./modules/iam_roles"
  project          = var.project
  env              = var.env
  data_bucket_arn  = module.data_lake_bucket.bucket_arn
  data_bucket_name = module.data_lake_bucket.bucket_name
  tags             = local.tags
}

module "redshift" {
  source              = "./modules/redshift_cluster"
  cluster_identifier  = var.cluster_identifier
  db_name             = var.db_name
  master_username     = var.master_username
  master_password     = var.master_password
  node_type           = var.node_type
  number_of_nodes     = var.number_of_nodes
  port                = var.port
  subnet_ids          = var.subnet_ids
  vpc_id              = var.vpc_id
  allowed_cidr        = var.allowed_cidr
  kms_key_id          = var.kms_key_id
  publicly_accessible = var.publicly_accessible
  redshift_role_arn   = module.iam.redshift_role_arn
  tags                = local.tags
}

module "catalog" {
  source                  = "./modules/glue_catalog"
  catalog_db_name         = var.catalog_db_name
  enable_crawler          = var.enable_crawler
  crawler_name            = var.crawler_name
  crawler_s3_targets      = var.crawler_s3_targets
  glue_crawler_role_arn   = module.iam.glue_role_arn
  tags                    = local.tags
  glue_jobs               = var.glue_jobs
  tags                    =local.tags
}


locals {
<<<<<<< Updated upstream
  tags = merge(
    {
      Environment = var.env
      Project     = var.project
    },
    var.tags
  )
}
=======
  project_name = var.project
  environment  = var.env
  tags = merge(var.tags, {
    ManagedBy = "terraform"
  })
}

# S3 bucket for medallion architecture
module "s3_bucket" {
  source = "./modules/s3_bucket"

  bucket_name = var.data_lake_bucket_name
  tags        = local.tags
}

# IAM roles for Glue and Redshift
module "iam_roles" {
  source = "./modules/iam_roles"

  project = local.project_name
  env     = local.environment

  # S3 bucket details for permissions
  data_bucket_name = var.data_lake_bucket_name
  data_bucket_arn  = module.s3_bucket.bucket_arn

  # DataEngineers user group
  data_engineers_group_name = "DataEngineers"

  # NEW: required inputs for the Redshift COPY role
  processed_bucket = var.processed_bucket
  processed_prefix = var.processed_prefix

  tags = local.tags
}


# Glue catalog and ETL jobs
module "glue" {
  source = "./modules/Glue"

  # Database and Crawler Configuration
  catalog_db_name = "assignment2_data_catalog"
  enable_crawler  = true
  crawler_name    = "assignment2-crawler"

  # S3 targets for medallion layers
  crawler_s3_targets = [
    "s3://${var.data_lake_bucket_name}/bronze/",
    "s3://${var.data_lake_bucket_name}/silver/",
    "s3://${var.data_lake_bucket_name}/gold/"
  ]

  # IAM roles
  glue_crawler_role_arn = module.iam_roles.glue_role_arn
  glue_role_arn         = module.iam_roles.glue_role_arn


  # Glue ETL jobs configuration 
  glue_jobs = {
    "bronze_to_silver" = {
      glue_version      = "4.0"
      worker_type       = "G.1X"
      number_of_workers = 2
      max_retries       = 2
      timeout_minutes   = 60
      description       = "Transform bronze data to silver layer"
      script_s3_path    = "s3://${var.data_lake_bucket_name}/scripts/bronze_to_silver_etl.py"
      default_args = {
        "--bronze_s3_path"  = "s3://${var.data_lake_bucket_name}/bronze/"
        "--silver_s3_path"  = "s3://${var.data_lake_bucket_name}/silver/"
        "--bronze_database" = "assignment2_bronze"
        "--silver_database" = "assignment2_silver"
      }
    }
    "silver_to_gold" = {
      glue_version      = "4.0"
      worker_type       = "G.1X"
      number_of_workers = 2
      max_retries       = 2
      timeout_minutes   = 60
      description       = "Transform silver data to gold layer"
      script_s3_path    = "s3://${var.data_lake_bucket_name}/scripts/silver_to_gold_etl.py"
      default_args = {
        "--silver_s3_path"  = "s3://${var.data_lake_bucket_name}/silver/"
        "--gold_s3_path"    = "s3://${var.data_lake_bucket_name}/gold/"
        "--silver_database" = "assignment2_silver"
        "--gold_database"   = "assignment2_gold"
      }
    }
  }

  tags = local.tags
}

# CloudWatch monitoring
module "cloudwatch_monitoring" {
  source = "./modules/cloudwatch_monitoring"

  project = local.project_name
  env     = local.environment

  # S3 bucket for monitoring
  bucket_name = var.data_lake_bucket_name

  # Glue job name for monitoring (using bronze-to-silver as primary)
  glue_job_name = "bronze-to-silver-etl"

  # Tags for all resources
  tags = local.tags
}


>>>>>>> Stashed changes

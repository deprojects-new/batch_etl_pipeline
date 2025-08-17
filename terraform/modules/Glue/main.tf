# Glue Catalog Database
resource "aws_glue_catalog_database" "this" {
  name = var.catalog_db_name
  
  tags = var.tags
}

# Glue Crawler
resource "aws_glue_crawler" "this" {
  count         = var.enable_crawler ? 1 : 0
  name          = var.crawler_name
  role          = var.glue_crawler_role_arn
  database_name = aws_glue_catalog_database.this.name

  dynamic "s3_target" {
    for_each = var.crawler_s3_targets
    content {
      path = s3_target.value
    }
  }

  tags = var.tags
}

# Glue ETL Jobs
resource "aws_glue_job" "job" {
  for_each = var.glue_jobs

  name              = "etl-${each.key}"
  role_arn          = var.glue_role_arn
  glue_version      = each.value.glue_version
  worker_type       = each.value.worker_type
  number_of_workers = each.value.number_of_workers
  max_retries       = each.value.max_retries
  timeout           = each.value.timeout_minutes
  description       = try(each.value.description, null)
  execution_class   = try(each.value.execution_class, null)
  connections       = try(each.value.connections, null)
 
  command {
    name            = "glueetl"
    script_location = each.value.script_s3_path
    python_version  = "3"
  }

  default_arguments = merge(
    {
      "--enable-metrics"                   = "true"
      "--enable-continuous-cloudwatch-log" = "true"
      "--job-language"                     = "python"
      "--additional-python-modules"        = "delta-spark==2.4.0"
      "--conf"                             = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
    },
    each.value.default_args
  )

  tags = merge(var.tags, {
    JobName = each.key
  })
}






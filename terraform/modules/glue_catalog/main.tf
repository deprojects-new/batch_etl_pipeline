resource "aws_glue_catalog_database" "this" {
  name = var.catalog_db_name
  
}

resource "aws_glue_crawler" "this" {
  count         = var.enable_crawler ? 1 : 0
  name          = var.crawler_name
  role          = var.glue_crawler_role_arn
  database_name = aws_glue_catalog_database.this.name

  dynamic "s3_target" {
    for_each = var.crawler_s3_targets
    content { path = s3_target.value }
  }
}
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
    },
    each.value.default_args
  )
}
module "catalog" {
  source = "./modules/glue_catalog"
  
  # other variables
  tags = local.tags
}

  crawler_name    = var.crawler_name
  crawler_s3_targets = var.crawler_s3_targets
  glue_jobs       = var.glue_jobs



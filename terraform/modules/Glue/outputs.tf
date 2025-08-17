output "catalog_db_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.this.name
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = var.enable_crawler ? aws_glue_crawler.this[0].name : null
}

output "glue_job_names" {
  description = "Names of all Glue ETL jobs"
  value       = [for job in aws_glue_job.job : job.name]
}

output "glue_job_arns" {
  description = "ARNs of all Glue ETL jobs"
  value       = [for job in aws_glue_job.job : job.arn]
}

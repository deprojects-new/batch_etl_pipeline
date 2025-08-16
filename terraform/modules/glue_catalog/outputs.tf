output "names" { value = { for k, j in aws_glue_job.job : k => j.name } }
output "db_name" { value = aws_glue_catalog_database.this.name }
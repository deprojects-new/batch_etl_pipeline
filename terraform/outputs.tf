output "raw_bucket"      { value = aws_s3_bucket.raw.bucket }
output "curated_bucket"  { value = aws_s3_bucket.curated.bucket }
output "stage_bucket"    { value = aws_s3_bucket.stage.bucket }


output "glue_database"   { value = aws_glue_catalog_database.this.name }


output "redshift_endpoint" { value = aws_redshift_cluster.this.endpoint }
output "redshift_database" { value = aws_redshift_cluster.this.database_name }
output "redshift_iam_role" { value = aws_iam_role.redshift_copy.arn }


output "databricks_job_id" { value = databricks_job.sales_batch.id }

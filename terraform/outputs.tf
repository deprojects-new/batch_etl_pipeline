output "bucket_name"        { value = module.data_lake_bucket.bucket_name }
output "redshift_endpoint"  { value = module.redshift.endpoint }
output "redshift_role_arn"  { value = module.iam.redshift_role_arn }
output "glue_role_arn"      { value = module.iam.glue_role_arn }
output "catalog_db_name"    { value = module.catalog.db_name }
output "glue_job_names"     { value = module.glue_jobs.names }
output "s3_bucket_name"         { value = module.s3_one_bucket.bucket }
output "s3_raw_prefix"          { value = module.s3_one_bucket.raw_prefix }
output "s3_curated_prefix"      { value = module.s3_one_bucket.curated_prefix }

output "glue_database_name"     { value = module.glue_catalog.database_name }
output "glue_crawler_name"      { value = module.glue_catalog.crawler_name }
output "glue_job_name"          { value = module.glue_job.job_name }

output "redshift_namespace"     { value = module.redshift_serverless.namespace_name }
output "redshift_workgroup"     { value = module.redshift_serverless.workgroup_name }
output "redshift_endpoint"      { value = module.redshift_serverless.endpoint }
output "redshift_port"          { value = module.redshift_serverless.port }

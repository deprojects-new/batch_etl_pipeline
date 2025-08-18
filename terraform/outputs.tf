output "bucket_name" { value = module.s3_bucket.bucket_name }
output "bucket_arn" { value = module.s3_bucket.bucket_arn }
output "glue_role_arn" { value = module.iam_roles.glue_role_arn }
# Redshift role ARN removed - Redshift is in personal account
output "copy_role_arn" {
  value       = module.iam_roles.copy_role_arn
  description = "IAM role used by Redshift COPY to read from S3"
}


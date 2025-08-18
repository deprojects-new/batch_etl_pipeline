output "glue_role_arn" { value = aws_iam_role.glue.arn }

# DataEngineers Policy Outputs
output "data_engineers_policy_arn" {
  description = "ARN of the DataEngineers IAM policy"
  value       = aws_iam_policy.data_engineers.arn
}

output "data_engineers_policy_name" {
  description = "Name of the DataEngineers IAM policy"
  value       = aws_iam_policy.data_engineers.name
}

# terraform/modules/iam_roles/outputs.tf
output "copy_role_arn" {
  value       = aws_iam_role.redshift_copy_role.arn
  description = "IAM role used by Redshift COPY to read S3"
}

# Output the IAM role ARN -  need this for Redshift configuration
output "redshift_role_arn" {
  description = "ARN of the Redshift IAM role for S3 access"
  value       = aws_iam_role.redshift_s3_role.arn
}

# Output the IAM role name
output "redshift_role_name" {
  description = "Name of the Redshift IAM role"
  value       = aws_iam_role.redshift_s3_role.name
}

# Output the IAM policy ARN
output "redshift_policy_arn" {
  description = "ARN of the Redshift S3 access policy"
  value       = aws_iam_policy.redshift_s3_policy.arn
}

# Output the account ID for verification
output "account_id" {
  description = "AWS Account ID where resources are created"
  value       = data.aws_caller_identity.current.account_id
}

# Get current caller identity for verification
data "aws_caller_identity" "current" {}

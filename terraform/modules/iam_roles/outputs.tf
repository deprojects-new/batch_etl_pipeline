output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}

output "redshift_copy_role_arn" {
  value = aws_iam_role.redshift_copy_role.arn
}

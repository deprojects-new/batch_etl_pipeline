# Create namespace
resource "aws_redshiftserverless_namespace" "ns" {
  namespace_name = var.namespace_name

  iam_roles = [var.redshift_copy_role_arn]
}

# Create workgroup attached to your VPC
resource "aws_redshiftserverless_workgroup" "wg" {
  workgroup_name = var.workgroup_name
  namespace_name = aws_redshiftserverless_namespace.ns.namespace_name

  base_capacity = 32 # RPU; adjust as needed

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
}

variable "namespace_name"         { type = string }
variable "workgroup_name"         { type = string }
variable "subnet_ids"             { type = list(string) }
variable "security_group_ids"     { type = list(string) }
variable "redshift_copy_role_arn" { type = string }

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

output "namespace_name" { value = aws_redshiftserverless_namespace.ns.namespace_name }
output "workgroup_name" { value = aws_redshiftserverless_workgroup.wg.workgroup_name }
output "endpoint"       { value = aws_redshiftserverless_workgroup.wg.endpoint }
output "port"           { value = aws_redshiftserverless_workgroup.wg.port }

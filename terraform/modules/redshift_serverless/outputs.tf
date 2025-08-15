output "namespace_name" { value = aws_redshiftserverless_namespace.ns.namespace_name }
output "workgroup_name" { value = aws_redshiftserverless_workgroup.wg.workgroup_name }
output "endpoint" { value = aws_redshiftserverless_workgroup.wg.endpoint }
output "port" { value = aws_redshiftserverless_workgroup.wg.port }
output "workgroup_arn" { value = aws_redshiftserverless_workgroup.wg.arn }

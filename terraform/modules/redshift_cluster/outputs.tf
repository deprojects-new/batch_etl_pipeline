<<<<<<< Updated upstream
#output "endpoint" { value = aws_redshift_cluster.this.endpoint }
=======


output "cluster_id" {
  description = "The Redshift cluster identifier"
  value       = aws_redshift_cluster.this.id
}

output "cluster_identifier" {
  description = "The Redshift cluster identifier"
  value       = aws_redshift_cluster.this.cluster_identifier
}

output "endpoint" {
  description = "The connection endpoint for the Redshift cluster"
  value       = aws_redshift_cluster.this.endpoint
}

output "port" {
  description = "The port number on which the cluster accepts connections"
  value       = aws_redshift_cluster.this.port
}

output "database_name" {
  description = "The name of the database in the cluster"
  value       = aws_redshift_cluster.this.database_name
}

output "master_username" {
  description = "The master username for the cluster"
  value       = aws_redshift_cluster.this.master_username
}

output "node_type" {
  description = "The node type of the cluster"
  value       = aws_redshift_cluster.this.node_type
}

output "cluster_type" {
  description = "The type of the cluster"
  value       = aws_redshift_cluster.this.cluster_type
}

output "number_of_nodes" {
  description = "The number of nodes in the cluster"
  value       = aws_redshift_cluster.this.number_of_nodes
}

output "cluster_subnet_group_name" {
  description = "The name of the subnet group for the cluster"
  value       = aws_redshift_cluster.this.cluster_subnet_group_name
}

output "vpc_security_group_ids" {
  description = "The VPC security group IDs associated with the cluster"
  value       = aws_redshift_cluster.this.vpc_security_group_ids
}

output "iam_role_arn" {
  description = "The ARN of the IAM role associated with the cluster"
  value       = aws_iam_role.redshift_s3.arn
}

output "subnet_group_id" {
  description = "The ID of the subnet group"
  value       = aws_redshift_subnet_group.this.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.redshift.id
}

output "parameter_group_id" {
  description = "The ID of the parameter group"
  value       = aws_redshift_parameter_group.this.id
}

output "effective_iam_roles" {
  description = "ARNs attached to the Redshift cluster"
  value       = aws_redshift_cluster.this.iam_roles
}

>>>>>>> Stashed changes

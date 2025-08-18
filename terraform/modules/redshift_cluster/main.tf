resource "aws_redshift_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnets"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "redshift" {
  name        = "${var.cluster_identifier}-sg"
  description = "Redshift access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


  tags = var.tags
}

resource "aws_redshift_parameter_group" "this" {
  name   = "${var.cluster_identifier}-params"
  family = "redshift-1.0"
  parameter { name = "require_ssl" value = "true" }
  tags = var.tags
}

resource "aws_redshift_cluster" "this" {
<<<<<<< Updated upstream
  cluster_identifier                  = var.cluster_identifier
  database_name                       = var.db_name
  master_username                     = var.master_username
  master_password                     = var.master_password
  node_type                           = var.node_type
  number_of_nodes                     = var.number_of_nodes
  port                                = var.port
  cluster_subnet_group_name           = aws_redshift_subnet_group.this.name
  publicly_accessible                 = var.publicly_accessible
  iam_roles                           = [var.redshift_role_arn]
  encrypted                           = true
  kms_key_id                          = var.kms_key_id != null ? var.kms_key_id : null
  vpc_security_group_ids              = [aws_security_group.redshift.id]
  cluster_parameter_group_name        = aws_redshift_parameter_group.this.name
  skip_final_snapshot                 = true

  tags = var.tags
=======
  cluster_identifier        = var.cluster_identifier
  database_name            = var.database_name
  master_username          = var.master_username
  master_password          = var.master_password
  node_type                = var.node_type
  cluster_type             = var.cluster_type
  number_of_nodes          = var.cluster_type == "single-node" ? null : var.number_of_nodes
  
  # Network configuration
  vpc_security_group_ids   = [aws_security_group.redshift.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.this.name
  
  # IAM role for S3 access
  iam_roles = compact([var.copy_role_arn, aws_iam_role.redshift_s3.arn])
  
  # Parameter group
  cluster_parameter_group_name = aws_redshift_parameter_group.this.name
  
  # Backup and maintenance
  automated_snapshot_retention_period = 1  # Required for ra3.large
  preferred_maintenance_window        = "sun:03:00-sun:04:00"
  
  # Encryption
  encrypted = true
  
  
  # Tags
  tags = merge(var.tags, {
    Name = var.cluster_identifier
  })
>>>>>>> Stashed changes
}

output "endpoint" { value = aws_redshift_cluster.this.endpoint }
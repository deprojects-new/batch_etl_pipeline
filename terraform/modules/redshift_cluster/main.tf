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
}

output "endpoint" { value = aws_redshift_cluster.this.endpoint }
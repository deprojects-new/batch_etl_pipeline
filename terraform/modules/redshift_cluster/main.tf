# Redshift Cluster Module

# Data sources for current region and VPC
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Get default VPC if not specified
data "aws_vpc" "default" {
  count = var.vpc_id == null ? 1 : 0
  default = true
}

# Get default subnets if not specified
data "aws_subnets" "default" {
  count = var.subnet_ids == null || length(var.subnet_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id]
  }
}

# Redshift Subnet Group
resource "aws_redshift_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids != null && length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.default[0].ids

  tags = merge(var.tags, {
    Name = "${var.cluster_identifier}-subnet-group"
  })
}

# Redshift Security Group
resource "aws_security_group" "redshift" {
  name_prefix = "${var.cluster_identifier}-redshift-sg"
  vpc_id      = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id

  # Allow Redshift port (5439) from specified CIDR
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr]
    description = "Redshift access from specified CIDR"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_identifier}-redshift-sg"
  })
}

# IAM Role for Redshift

data "aws_iam_policy_document" "redshift_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "redshift_s3" {
  name               = "${var.cluster_identifier}-redshift-s3-role"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume.json

  tags = merge(var.tags, {
    Name = "${var.cluster_identifier}-redshift-s3-role"
  })
}

# Policy for Redshift to access S3
data "aws_iam_policy_document" "redshift_s3_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::assignment2-data-lake",
      "arn:aws:s3:::assignment2-data-lake/*"
    ]
  }
}

resource "aws_iam_policy" "redshift_s3" {
  name        = "${var.cluster_identifier}-redshift-s3-policy"
  description = "Policy for Redshift to access S3 data lake"
  policy      = data.aws_iam_policy_document.redshift_s3_policy.json

  tags = merge(var.tags, {
    Name = "${var.cluster_identifier}-redshift-s3-policy"
  })
}

resource "aws_iam_role_policy_attachment" "redshift_s3" {
  role       = aws_iam_role.redshift_s3.name
  policy_arn = aws_iam_policy.redshift_s3.arn
}

# Redshift Parameter Group
resource "aws_redshift_parameter_group" "this" {
  name   = "${var.cluster_identifier}-parameter-group"
  family = "redshift-1.0"

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }

  parameter {
    name  = "log_connections"
    value = "true"
  }

  parameter {
    name  = "log_disconnections"
    value = "true"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_identifier}-parameter-group"
  })
}

# Redshift Cluster
resource "aws_redshift_cluster" "this" {
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
  iam_roles = [aws_iam_role.redshift_s3.arn]
  
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
}

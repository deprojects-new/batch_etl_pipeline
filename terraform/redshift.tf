resource "aws_redshift_subnet_group" "this" {
  count      = length(var.subnet_ids) > 0 ? 1 : 0
  name       = "${var.project}-${var.env}-rs-subnets"
  subnet_ids = var.subnet_ids
}


resource "aws_redshift_cluster" "this" {
  cluster_identifier  = "${var.project}-${var.env}-rs"
  node_type           = var.redshift_node_type
  number_of_nodes     = var.redshift_node_count
  master_username     = var.redshift_user
  master_password     = var.redshift_password
  database_name       = "dev"
  publicly_accessible = true                                  # demo only
  iam_roles           = [aws_iam_role.redshift_copy.arn]


  # network (optional)
  cluster_subnet_group_name = length(var.subnet_ids) > 0 ? aws_redshift_subnet_group.this[0].name : null
  vpc_security_group_ids    = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : null
}


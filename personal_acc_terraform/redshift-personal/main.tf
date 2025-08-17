terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "redshift_cluster" {
  source = "../../terraform/modules/redshift_cluster"
  
  cluster_identifier = "sales-redshift-personal"
  database_name     = "sales_analytics"
  master_username   = "admin"
  master_password   = var.redshift_password
  
  # Simple configuration
  node_type      = "ra3.large"
  cluster_type   = "single-node"
  number_of_nodes = 1
  
  # Use default VPC
  vpc_id         = null
  subnet_ids     = []
  ingress_cidr   = "0.0.0.0/0"  # Change to your IP later
  
  # Tags
  tags = {
    Project = "batch-etl-pipeline"
    Owner   = "Personal"
    Account = "Personal"
  }
}

# Outputs
output "redshift_endpoint" {
  value = module.redshift_cluster.endpoint
}

output "redshift_database" {
  value = module.redshift_cluster.cluster_id
}

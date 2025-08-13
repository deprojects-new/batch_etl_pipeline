terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws        = { source = "hashicorp/aws",        version = ">= 5.40" }
    databricks = { source = "databricks/databricks", version = ">= 1.57" }
    random     = { source = "hashicorp/random",     version = ">= 3.6" }
  }
}
provider "aws" {
  region = var.region


  default_tags {
    tags = {
      Project   = var.project
      Env       = var.env
      ManagedBy = "Terraform"
    }
  }
}

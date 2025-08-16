provider "aws" {
  region = var.aws_region

  default_tags = {
    Environment = var.env
    Project     = var.project
  }
}

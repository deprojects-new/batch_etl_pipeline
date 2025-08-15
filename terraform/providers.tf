provider "aws" {
  region = var.region

  default_tags {
    tags = merge({
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terraform"
    }, var.tags)
  }
}

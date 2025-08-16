terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60" # any recent 5.x works
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  # backend "local" {}  # or your remote backend if you use one
}

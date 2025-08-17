variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "data_lake_bucket_name" {
  description = "Name of the data lake S3 bucket"
  type        = string
  default     = "assignment2-data-lake"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "assignment2"
}

variable "users" {
  description = "List of users"
  type        = list(string)
  default     = ["Abhinav", "Priya", "Srinidhi"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Owner       = "Jeevan"
    Environment = "dev"
    Project     = "assignment2"
  }
}









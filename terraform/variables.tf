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

feature/Jeevan
Updated upstream
variable "data_bucket_name" {
  type        = string
  description = "Name of the main S3 bucket"
}
=======
# ... keep your existing variables ...

# S3 bucket NAME (not ARN) that holds the processed data your COPY reads from
variable "processed_bucket" {
  description = "S3 bucket name for processed data (no ARN)"
  type        = string
}

# Prefix under that bucket (no leading slash, no trailing slash)
# e.g., "processed/sales" or "gold/sales"
variable "processed_prefix" {
  description = "S3 prefix under the bucket to load from (no leading slash)"
  type        = string
  validation {
    condition     = !(can(regex("^/", var.processed_prefix)))
    error_message = "processed_prefix must not start with '/'. Use 'processed/sales', not '/processed/sales'."
  }
}




Stashed changes
main








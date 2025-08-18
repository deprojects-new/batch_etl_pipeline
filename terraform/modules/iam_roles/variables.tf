# modules/iam_roles/variables.tf

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "data_bucket_name" {
  type = string
}

variable "data_bucket_arn" {
  type = string
}

variable "data_engineers_group_name" {
  type        = string
  description = "Name of the existing DataEngineers user group"
  default     = "DataEngineers"
}

variable "processed_bucket" {
  description = "S3 bucket name with processed/gold data (no ARN)"
  type        = string
}
variable "processed_prefix" {
  description = "Prefix under bucket, e.g., 'gold' or 'gold/SalesWide' (no leading slash)"
  type        = string
}

# Add this (only once in this module)
variable "tags" {
<<<<<<< Updated upstream
  type    = map(string)
  default = {}
}

# modules/iam_roles/variables.tf
variable "processed_bucket" {
  type        = string
  description = "S3 bucket name that holds processed data (no arn, just the name)"
}

variable "processed_prefix" {
  type        = string
  description = "S3 prefix under the bucket that Redshift should read from (no leading slash)"
=======
  type        = map(string)
  description = "Common tags applied to IAM resources in this module"
  default     = {}   # lets the module work even if the root doesn't pass tags
>>>>>>> Stashed changes
}

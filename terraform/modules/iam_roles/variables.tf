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

variable "tags" {
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
}

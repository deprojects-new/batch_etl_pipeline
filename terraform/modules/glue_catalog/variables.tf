variable "database_name" {
  type        = string
  description = "Glue Catalog database name."
}

variable "s3_raw_path" {
  type        = string
  description = "s3://bucket/raw/ path for the crawler."
}

variable "glue_role_arn" {
  type        = string
  description = "IAM role ARN for Glue (crawler + job)."
}

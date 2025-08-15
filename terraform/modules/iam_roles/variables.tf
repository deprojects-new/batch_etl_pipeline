variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket."
}

variable "bucket_raw_prefix_arn" {
  type        = string
  description = "ARN for raw prefix objects (e.g., arn:aws:s3:::bucket/raw/*)."
}

variable "bucket_scripts_prefix_arn" {
  type        = string
  description = "ARN for scripts prefix objects (e.g., arn:aws:s3:::bucket/scripts/*)."
}

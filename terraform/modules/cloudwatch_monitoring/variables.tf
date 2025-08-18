variable "project" {
  type        = string
  description = "Project name for resource naming"
}

variable "env" {
  type        = string
  description = "Environment name for resource naming"
}

# Glue Job Monitoring
variable "glue_job_name" {
  type        = string
  description = "Glue job name to watch for FAILED events"
}

# S3 Bucket Monitoring
variable "bucket_name" {
  type        = string
  description = "S3 bucket name to monitor for errors"
}

variable "enable_s3_alarms" {
  type        = bool
  default     = true
  description = "Enable S3 4xx/5xx error alarms"
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}


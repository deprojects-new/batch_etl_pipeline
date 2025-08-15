variable "project" { type = string }
variable "env"     { type = string }

# Alerts
variable "alert_email" {
  type        = string
  default     = ""
  description = "Optional: email for SNS subscription (leave empty to skip)."
}

# Glue
variable "glue_job_name" {
  type        = string
  description = "Glue job name to watch for FAILED events."
}

# S3
variable "bucket_name" {
  type        = string
  description = "Monitored S3 bucket name (for 4xx/5xx alarms)."
}
variable "enable_s3_alarms" {
  type        = bool
  default     = true
  description = "Toggle S3 4xx/5xx alarms."
}

# Redshift Serverless
variable "redshift_workgroup_name" {
  type        = string
  description = "Redshift Serverless workgroup to monitor."
}
variable "enable_redshift_alarm" {
  type        = bool
  default     = true
  description = "Toggle Redshift RPUUtilization alarm."
}
variable "redshift_rpu_threshold" {
  type        = number
  default     = 80
  description = "Average RPUUtilization threshold percentage."
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "env" {
  type        = string
  description = "Environment (e.g., dev, prod)"
}

variable "project" {
  type        = string
  description = "Project name tag"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

variable "data_bucket_name" {
  type        = string
  description = "Name of the main S3 bucket"
}

variable "glue_jobs" {
  type = map(object({
    script_s3_path     = string
    glue_version       = string
    worker_type        = string
    number_of_workers  = number
    max_retries        = number
    timeout_minutes    = number
    default_args       = map(string)
    execution_class    = optional(string)
    connections        = optional(list(string), [])
    description        = optional(string)
  }))
  description = "Map of Glue jobs to create"
}
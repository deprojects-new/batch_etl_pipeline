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

<<<<<<< Updated upstream
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




>>>>>>> Stashed changes

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
# Glue Catalog Database Configuration
variable "catalog_db_name" {
  type        = string
  description = "Glue Catalog database name"
  default     = "assignment2_data_catalog"
}

# Crawler Configuration
variable "enable_crawler" {
  type        = bool
  description = "Enable or disable crawler provisioning"
  default     = true
}

variable "crawler_name" {
  type        = string
  description = "Name of the Glue crawler"
  default     = "assignment2-crawler"
}

variable "crawler_s3_targets" {
  type        = list(string)
  description = "List of S3 paths the crawler should scan"
  default     = []
}

# IAM Role Configuration
variable "glue_crawler_role_arn" {
  type        = string
  description = "IAM role ARN for the Glue crawler"
}

variable "glue_role_arn" {
  type        = string
  description = "IAM role ARN for Glue ETL jobs"
}

# Glue ETL Jobs Configuration
variable "glue_jobs" {
  type = map(object({
    script_s3_path    = string
    glue_version      = string
    worker_type       = string
    number_of_workers = number
    max_retries       = number
    timeout_minutes   = number
    default_args      = map(string)
    execution_class   = optional(string)
    connections       = optional(list(string), [])
    description       = optional(string)
  }))
  default     = {}
  description = "Map of Glue jobs (key = job name)"
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags for Glue resources"
  default     = {}
}

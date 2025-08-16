// modules/glue_catalog/variables.tf
variable "catalog_db_name" {
  type = string
}

variable "enable_crawler" {
  type    = bool
  default = false
}

variable "crawler_name" {
  type    = string
  default = "etl-crawler"
}

variable "crawler_s3_targets" {
  type = list(string)
}

variable "glue_jobs" {
  description = "Optional map of Glue job definitions to create"
  type = map(object({
    script_location    = string
    glue_version       = string
    worker_type        = string
    number_of_workers  = number
    timeout_minutes    = number
    default_args       = map(string)
  }))
  default = {}
}

variable "glue_crawler_role_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
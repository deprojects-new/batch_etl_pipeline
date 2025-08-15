variable "bucket_base_name" {
  description = "Base for bucket name; a short random suffix is appended for global uniqueness."
  type        = string
}

variable "project" { type = string }
variable "env" { type = string }

variable "raw_prefix" {
  type        = string
  default     = "raw/"
  description = "S3 key prefix for raw zone (must end with '/')."
}

variable "curated_prefix" {
  type        = string
  default     = "curated/"
  description = "S3 key prefix for curated zone (must end with '/')."
}

variable "scripts_prefix" {
  type        = string
  default     = "scripts/"
  description = "S3 key prefix for job scripts (must end with '/')."
}

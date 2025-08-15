variable "job_name"          { type = string }
variable "glue_role_arn"     { type = string }
variable "bucket_name"       { type = string }
variable "script_local_path" { type = string } # e.g., ../src/glue_scripts/etl_script.py
variable "script_s3_key"     { type = string } # e.g., scripts/etl_script.py

variable "python_version" {
  type    = string
  default = "3"
}

variable "worker_type" {
  type    = string
  default = "G.1X"
}

variable "number_of_workers" {
  type    = number
  default = 2
}

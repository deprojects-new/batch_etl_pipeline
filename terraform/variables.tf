variable "region" { type = string }
variable "project" { type = string }
variable "env" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

# S3 (single bucket with prefixes)
variable "bucket_base_name" {
  description = "Base name; a random suffix is added for global uniqueness"
  type        = string
}

# Glue
variable "glue_job_name" { type = string }
variable "glue_python_version" {
  type    = string
  default = "3" # Glue 4.0 uses Python 3
}
variable "glue_worker_type" {
  type    = string
  default = "G.1X"
}
variable "glue_number_workers" {
  type    = number
  default = 2
}
variable "glue_script_local_path" {
  description = "Relative path in your repo to the Glue job script (e.g., ../src/glue_scripts/etl_script.py)"
  type        = string
}

# Redshift Serverless (you must supply VPC subnets and security groups)
variable "redshift_namespace_name" { type = string }
variable "redshift_workgroup_name" { type = string }
variable "vpc_subnet_ids" {
  description = "List of private subnet IDs for Redshift Serverless"
  type        = list(string)
}
variable "vpc_security_group_ids" {
  description = "Security group IDs allowing Redshift access"
  type        = list(string)
}

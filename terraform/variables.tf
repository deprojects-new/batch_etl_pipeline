variable "project" { type = string  default = "etl-pipeline" }
variable "env"     { type = string  default = "dev" }
variable "region"  { type = string  default = "us-east-1" }


# Redshift (demo defaults)
variable "redshift_user"     { type = string  default = "admin" }
variable "redshift_password" { type = string  sensitive = true }
variable "redshift_node_type"{ type = string  default = "dc2.large" }
variable "redshift_node_count" { type = number default = 1 }


# Networking (set these if you want private networking; otherwise cluster is public)
variable "subnet_ids" { type = list(string) default = [] } # optional
variable "vpc_security_group_ids" { type = list(string) default = [] } # optional


# Notebooks relative path (from repo root)
variable "dbx_notebooks_path" {
  type    = string
  default = "../databricks/notebooks"
}


# Databricks job cluster config (keep small for demo)
variable "dbx_spark_version" { type = string default = "13.3.x-scala2.12" }
variable "dbx_node_type"     { type = string default = "i3.xlarge" }
variable "dbx_num_workers"   { type = number default = 2 }
variable "cluster_identifier"  { type = string }
variable "db_name"             { type = string }
variable "master_username"     { type = string }
variable "master_password"     { 
    type = string 
sensitive = true 
}
variable "node_type"           { type = string }
variable "number_of_nodes"     { type = number }
variable "port"                { type = number }
variable "subnet_ids"          { type = list(string) }
variable "vpc_id"              { type = string }
variable "allowed_cidr"        { type = list(string) }
variable "kms_key_id"          { 
    type = string  
default = null 
}
<<<<<<< Updated upstream
variable "publicly_accessible" { 
    type = bool    
    default = false
     }
variable "redshift_role_arn"   { type = string }
variable "tags"                { 
    type = map(string)
     default = {} 
     }
=======

variable "copy_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN for Redshift COPY (optional)."
}

>>>>>>> Stashed changes

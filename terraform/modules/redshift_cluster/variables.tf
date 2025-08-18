 feature/Jeevan
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
 Updated upstream
variable "publicly_accessible" { 
    type = bool    
    default = false
     }
variable "redshift_role_arn"   { type = string }
variable "tags"                { 
    type = map(string)
     default = {} 
     }


variable "copy_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN for Redshift COPY (optional)."
}

Stashed changes

# Redshift Cluster Module Variables

variable "cluster_identifier" {
  type        = string
  description = "Unique identifier for the Redshift cluster"
}

variable "database_name" {
  type        = string
  description = "Name of the database to create in the cluster"
}

variable "master_username" {
  type        = string
  description = "Master username for the Redshift cluster"
  default     = "admin"
}

variable "master_password" {
  type        = string
  description = "Master password for the Redshift cluster"
  sensitive   = true
}

variable "node_type" {
  type        = string
  description = "Node type for the Redshift cluster"
  default     = "ra3.large"
}

variable "cluster_type" {
  type        = string
  description = "Type of cluster (single-node or multi-node)"
  default     = "single-node"
  validation {
    condition     = contains(["single-node", "multi-node"], var.cluster_type)
    error_message = "Cluster type must be either 'single-node' or 'multi-node'."
  }
}

variable "number_of_nodes" {
  type        = number
  description = "Number of nodes in the cluster (required for multi-node)"
  default     = 1
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the cluster will be created (null for default VPC)"
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the cluster (empty for default subnets)"
  default     = []
}

variable "ingress_cidr" {
  type        = string
  description = "CIDR block allowed to access Redshift (0.0.0.0/0 for any IP)"
  default     = "0.0.0.0/0"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
main

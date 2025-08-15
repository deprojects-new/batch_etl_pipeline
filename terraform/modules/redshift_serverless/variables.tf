variable "namespace_name" { type = string }
variable "workgroup_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "redshift_copy_role_arn" { type = string }

variable "base_capacity" {
  description = "RPU capacity for the workgroup."
  type        = number
  default     = 32
}

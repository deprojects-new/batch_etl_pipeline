variable "data_lake_bucket_name" {
  description = "Name of the S3 bucket to store the data lake"
  type        = string
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default     = {}  # empty map by default
}

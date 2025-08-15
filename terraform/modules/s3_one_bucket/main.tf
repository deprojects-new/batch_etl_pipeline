variable "bucket_base_name" { type = string }
variable "project"          { type = string }
variable "env"              { type = string }

resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  name = "${var.bucket_base_name}-${var.env}-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "this" {
  bucket = local.name
}

resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create logical "folders"
resource "aws_s3_object" "raw_prefix" {
  bucket = aws_s3_bucket.this.id
  key    = "raw/"
  content = ""
}

resource "aws_s3_object" "curated_prefix" {
  bucket = aws_s3_bucket.this.id
  key    = "curated/"
  content = ""
}

resource "aws_s3_object" "scripts_prefix" {
  bucket = aws_s3_bucket.this.id
  key    = "scripts/"
  content = ""
}

output "bucket"                 { value = aws_s3_bucket.this.bucket }
output "bucket_arn"             { value = aws_s3_bucket.this.arn }
output "raw_prefix"             { value = aws_s3_object.raw_prefix.key }
output "curated_prefix"         { value = aws_s3_object.curated_prefix.key }
output "scripts_prefix"         { value = aws_s3_object.scripts_prefix.key }
output "raw_prefix_arn"         { value = "${aws_s3_bucket.this.arn}/raw/*" }
output "scripts_prefix_arn"     { value = "${aws_s3_bucket.this.arn}/scripts/*" }

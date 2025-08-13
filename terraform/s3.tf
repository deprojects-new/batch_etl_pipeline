resource "aws_s3_bucket" "raw"     { bucket = local.raw_bucket }
resource "aws_s3_bucket" "curated" { bucket = local.curated_bucket }
resource "aws_s3_bucket" "stage"   { bucket = local.stage_bucket }


resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_versioning" "curated" {
  bucket = aws_s3_bucket.curated.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_versioning" "stage" {
  bucket = aws_s3_bucket.stage.id
  versioning_configuration { status = "Enabled" }
}


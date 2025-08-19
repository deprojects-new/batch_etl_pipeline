resource "aws_s3_bucket" "this" {
  bucket = var.data_lake_bucket_name
  tags   = var.tags
}



resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

# S3 bucket policy to allow cross-account access from personal Redshift
resource "aws_s3_bucket_policy" "cross_account_access" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPersonalAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::872515279539:root" # Allow mt personal account
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" : "872515279539"
          }
        }
      }
    ]
  })
}

# Create medallion folder structure
resource "aws_s3_object" "bronze_folder" {
  bucket  = var.data_lake_bucket_name
  key     = "bronze/"
  content = ""
}

resource "aws_s3_object" "silver_folder" {
  bucket  = var.data_lake_bucket_name
  key     = "silver/"
  content = ""
}

resource "aws_s3_object" "gold_folder" {
  bucket  = var.data_lake_bucket_name
  key     = "gold/"
  content = ""
}

resource "aws_s3_object" "scripts_folder" {
  bucket  = var.data_lake_bucket_name
  key     = "scripts/"
  content = ""
}

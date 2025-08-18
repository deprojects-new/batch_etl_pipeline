resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
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
feature/Jeevan
Updated upstream
}

main
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
  bucket = aws_s3_bucket.this.id
  key    = "bronze/"
  source = "/dev/null"
}

resource "aws_s3_object" "silver_folder" {
  bucket = aws_s3_bucket.this.id
  key    = "silver/"
  source = "/dev/null" # Empty file to create folder
}

resource "aws_s3_object" "gold_folder" {
  bucket = aws_s3_bucket.this.id
  key    = "gold/"
  source = "/dev/null" # Empty file to create folder
}

resource "aws_s3_object" "scripts_folder" {
  bucket = aws_s3_bucket.this.id
  key    = "scripts/"
  source = "/dev/null" # Empty file to create folder
feature/Jeevan
}

Stashed changes

}
main

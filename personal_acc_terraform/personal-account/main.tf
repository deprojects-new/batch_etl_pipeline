terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# IAM Role for Redshift to access S3 data lake
resource "aws_iam_role" "redshift_s3_role" {
  name = "assignment2-redshift-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  description = "Role for Redshift to access S3 data lake in main's account"
  
  tags = {
    Project     = "assignment2"
    Environment = "dev"
    Owner       = "Personal"
    Purpose     = "Redshift-S3-Access"
  }
}

# IAM Policy for S3 access
resource "aws_iam_policy" "redshift_s3_policy" {
  name = "assignment2-redshift-s3-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::assignment2-data-lake",
          "arn:aws:s3:::assignment2-data-lake/*"
        ]
      }
    ]
  })
  
  description = "Policy for Redshift to access S3 data lake in mains's account"
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "redshift_s3_attachment" {
  role       = aws_iam_role.redshift_s3_role.name
  policy_arn = aws_iam_policy.redshift_s3_policy.arn
}

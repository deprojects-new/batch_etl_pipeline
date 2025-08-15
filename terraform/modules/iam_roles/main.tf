variable "bucket_arn"                { type = string }
variable "bucket_raw_prefix_arn"     { type = string }
variable "bucket_scripts_prefix_arn" { type = string }

# ---- Glue Role (for Job + Crawler) ----
data "aws_iam_policy_document" "glue_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["glue.amazonaws.com"] }
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "GlueServiceRole-ETL"
  assume_role_policy = data.aws_iam_policy_document.glue_trust.json
}

# Managed Glue policy gives job/crawler baseline perms
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# S3 access (raw + scripts)
data "aws_iam_policy_document" "glue_s3_access" {
  statement {
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [
      var.bucket_arn,
      var.bucket_raw_prefix_arn,
      var.bucket_scripts_prefix_arn
    ]
  }
}

resource "aws_iam_policy" "glue_s3" {
  name   = "GlueS3Access"
  policy = data.aws_iam_policy_document.glue_s3_access.json
}

resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3.arn
}

# ---- Redshift COPY role (assumed by Redshift to read S3) ----
data "aws_iam_policy_document" "redshift_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["redshift.amazonaws.com"] }
  }
}

resource "aws_iam_role" "redshift_copy_role" {
  name               = "RedshiftCopyRole"
  assume_role_policy = data.aws_iam_policy_document.redshift_trust.json
}

data "aws_iam_policy_document" "redshift_s3_access" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [var.bucket_arn, var.bucket_raw_prefix_arn]
  }
}

resource "aws_iam_policy" "redshift_s3" {
  name   = "RedshiftS3Read"
  policy = data.aws_iam_policy_document.redshift_s3_access.json
}

resource "aws_iam_role_policy_attachment" "redshift_s3_attach" {
  role       = aws_iam_role.redshift_copy_role.name
  policy_arn = aws_iam_policy.redshift_s3.arn
}

output "glue_role_arn"            { value = aws_iam_role.glue_role.arn }
output "redshift_copy_role_arn"   { value = aws_iam_role.redshift_copy_role.arn }

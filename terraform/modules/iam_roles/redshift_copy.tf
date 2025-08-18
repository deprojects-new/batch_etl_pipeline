<<<<<<< Updated upstream
############################################
# Redshift COPY role (no duplicate data)
############################################

# expects vars:
#   - var.processed_bucket  (e.g., "assignment2-data-lake")
#   - var.processed_prefix  (e.g., "gold/sales")

resource "aws_iam_role" "redshift_copy_role" {
  name = "redshift-copy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "redshift.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
=======
# Trust policy for Redshift
data "aws_iam_policy_document" "redshift_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

# Role Redshift will assume for COPY
resource "aws_iam_role" "redshift_copy_role" {
  name               = "redshift-copy-role"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume.json
  tags               = var.tags
}

# Least-privilege S3 read on your processed prefix
data "aws_iam_policy_document" "redshift_copy_s3" {
  statement {
    sid     = "ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${var.processed_bucket}"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.processed_prefix}/*"]
    }
  }

  statement {
    sid       = "GetObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.processed_bucket}/${var.processed_prefix}/*"]
  }
>>>>>>> Stashed changes
}

resource "aws_iam_policy" "redshift_copy_s3" {
  name        = "redshift-copy-s3-read"
<<<<<<< Updated upstream
  description = "Allow Redshift COPY to read processed data"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "ListBucket",
        Effect: "Allow",
        Action: ["s3:ListBucket"],
        Resource: "arn:aws:s3:::${var.processed_bucket}",
        Condition: { StringLike: { "s3:prefix": ["${var.processed_prefix}/*"] } }
      },
      {
        Sid: "GetObjects",
        Effect: "Allow",
        Action: ["s3:GetObject"],
        Resource: "arn:aws:s3:::${var.processed_bucket}/${var.processed_prefix}/*"
      }
    ]
  })
=======
  description = "Allow Redshift COPY to read processed parquet"
  policy      = data.aws_iam_policy_document.redshift_copy_s3.json
  tags        = var.tags
>>>>>>> Stashed changes
}

resource "aws_iam_role_policy_attachment" "attach_copy" {
  role       = aws_iam_role.redshift_copy_role.name
  policy_arn = aws_iam_policy.redshift_copy_s3.arn
}
<<<<<<< Updated upstream

output "copy_role_arn" {
  value       = aws_iam_role.redshift_copy_role.arn
  description = "IAM role used by Redshift COPY to read from S3 processed prefix"
}
=======
>>>>>>> Stashed changes

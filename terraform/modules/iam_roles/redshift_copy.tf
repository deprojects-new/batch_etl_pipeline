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
}

resource "aws_iam_policy" "redshift_copy_s3" {
  name        = "redshift-copy-s3-read"
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
}

resource "aws_iam_role_policy_attachment" "attach_copy" {
  role       = aws_iam_role.redshift_copy_role.name
  policy_arn = aws_iam_policy.redshift_copy_s3.arn
}

output "copy_role_arn" {
  value       = aws_iam_role.redshift_copy_role.arn
  description = "IAM role used by Redshift COPY to read from S3 processed prefix"
}

# Glue job role
data "aws_iam_policy_document" "glue_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
  type        = "Service"
  identifiers = ["redshift.amazonaws.com"]
}

}

resource "aws_iam_role" "glue" {
  name               = "${var.project}-${var.env}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
  tags               = var.tags
}

# Access to S3 data bucket + logs (tighten as needed)
data "aws_iam_policy_document" "glue_policy" {
  statement {
    actions   = ["s3:GetObject","s3:PutObject","s3:ListBucket"]
    resources = [var.data_bucket_arn, "${var.data_bucket_arn}/*"]
  }
  statement {
    actions   = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "glue" {
  name   = "${var.project}-${var.env}-glue-policy"
  policy = data.aws_iam_policy_document.glue_policy.json
}

resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.glue.arn
}

# Redshift S3 role for COPY/UNLOAD
data "aws_iam_policy_document" "redshift_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service"
     identifiers = ["redshift.amazonaws.com"] 
     }
  }
}

resource "aws_iam_role" "redshift_s3" {
  name               = "${var.project}-${var.env}-redshift-s3"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "redshift_s3_policy" {
  statement {
    actions   = ["s3:GetObject","s3:PutObject","s3:ListBucket"]
    resources = [var.data_bucket_arn, "${var.data_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "redshift_s3" {
  name   = "${var.project}-${var.env}-redshift-s3"
  policy = data.aws_iam_policy_document.redshift_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "redshift_attach" {
  role       = aws_iam_role.redshift_s3.name
  policy_arn = aws_iam_policy.redshift_s3.arn
}
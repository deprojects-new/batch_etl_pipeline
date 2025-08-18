# Glue job role
data "aws_iam_policy_document" "glue_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue" {
  name               = "${var.project}-${var.env}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
  tags               = var.tags
}

# Access to S3 data bucket + logs + Glue services
data "aws_iam_policy_document" "glue_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "s3:DeleteObject"]
    resources = [var.data_bucket_arn, "${var.data_bucket_arn}/*"]
  }
  statement {
    actions   = ["s3:GetBucketLocation", "s3:GetBucketVersioning"]
    resources = [var.data_bucket_arn]
  }
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
  statement {
    actions   = ["glue:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["ec2:DescribeVpcEndpoints", "ec2:DescribeRouteTables", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
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

# DataEngineers User Group Policy

# IAM Policy for DataEngineers User Group
data "aws_iam_policy_document" "data_engineers" {
  # S3 Access - Full access to assignment2-data-lake bucket
  statement {
    sid    = "S3FullAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl"
    ]
    resources = [
      var.data_bucket_arn,
      "${var.data_bucket_arn}/*"
    ]
  }

  # Glue Catalog Access - Full access to assignment2_data_catalog
  statement {
    sid    = "GlueCatalogAccess"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:BatchCreatePartition",
      "glue:BatchDeletePartition",
      "glue:UpdatePartition"
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/assignment2_data_catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/assignment2_data_catalog/*",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:partition/assignment2_data_catalog/*"
    ]
  }

  # Glue Jobs Access - Full access to specific ETL jobs
  statement {
    sid    = "GlueJobsAccess"
    effect = "Allow"
    actions = [
      "glue:GetJob",
      "glue:GetJobs",
      "glue:StartJobRun",
      "glue:StopJobRun",
      "glue:GetJobRun",
      "glue:GetJobRuns",
      "glue:BatchStopJobRun",
      "glue:UpdateJob"
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:job/etl-bronze_to_silver",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:job/etl-silver_to_gold"
    ]
  }

  # Glue Crawler Access - Full access to assignment2-crawler
  statement {
    sid    = "GlueCrawlerAccess"
    effect = "Allow"
    actions = [
      "glue:GetCrawler",
      "glue:GetCrawlers",
      "glue:StartCrawler",
      "glue:StopCrawler",
      "glue:UpdateCrawler",
      "glue:GetCrawlerMetrics"
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:crawler/assignment2-crawler"
    ]
  }

  # CloudWatch Access - View metrics and logs
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:DescribeAlarms",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }

  # IAM Read Access - View roles and policies
  statement {
    sid    = "IAMReadAccess"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListAttachedRolePolicies"
    ]
    resources = ["*"]
  }

  # Glue Service Access - For job execution
  statement {
    sid    = "GlueServiceAccess"
    effect = "Allow"
    actions = [
      "glue:CreateSecurityConfiguration",
      "glue:GetSecurityConfiguration",
      "glue:GetSecurityConfigurations"
    ]
    resources = ["*"]
  }
}

# Data sources for current region and account
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Create the DataEngineers policy
resource "aws_iam_policy" "data_engineers" {
  name        = "${var.project}-${var.env}-data-engineers-policy"
  description = "Policy for DataEngineers user group access to data infrastructure"
  policy      = data.aws_iam_policy_document.data_engineers.json
  tags        = var.tags
}

# Attach policy to existing DataEngineers user group
resource "aws_iam_group_policy_attachment" "data_engineers" {
  group      = var.data_engineers_group_name
  policy_arn = aws_iam_policy.data_engineers.arn
}

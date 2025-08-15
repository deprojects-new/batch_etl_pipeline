############################################
# SNS topic for all alerts
############################################
resource "aws_sns_topic" "alerts" {
  name = "${var.project}-${var.env}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

############################################
# Glue Job FAILED → EventBridge → SNS
############################################
# Allow EventBridge to publish to SNS via role
data "aws_iam_policy_document" "events_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "events_to_sns_role" {
  name               = "${var.project}-${var.env}-events-to-sns"
  assume_role_policy = data.aws_iam_policy_document.events_trust.json
}

data "aws_iam_policy_document" "events_publish_sns" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
  }
}

resource "aws_iam_policy" "events_publish_sns" {
  name   = "${var.project}-${var.env}-events-publish-sns"
  policy = data.aws_iam_policy_document.events_publish_sns.json
}

resource "aws_iam_role_policy_attachment" "events_publish_sns" {
  role       = aws_iam_role.events_to_sns_role.name
  policy_arn = aws_iam_policy.events_publish_sns.arn
}

# EventBridge rule for Glue Job state change → FAILED
resource "aws_cloudwatch_event_rule" "glue_job_failed" {
  name = "${var.project}-${var.env}-glue-job-failed"

  event_pattern = jsonencode({
    "source" : ["aws.glue"],
    "detail-type" : ["Glue Job State Change"],
    "detail" : {
      "jobName" : [var.glue_job_name],
      "state" : ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "glue_job_failed_to_sns" {
  rule     = aws_cloudwatch_event_rule.glue_job_failed.name
  arn      = aws_sns_topic.alerts.arn
  role_arn = aws_iam_role.events_to_sns_role.arn
}

############################################
# S3 4xx / 5xx alarms (EntireBucket)
############################################
resource "aws_cloudwatch_metric_alarm" "s3_4xx" {
  count               = var.enable_s3_alarms ? 1 : 0
  alarm_name          = "${var.project}-${var.env}-s3-4xx-errors"
  namespace           = "AWS/S3"
  metric_name         = "4xxErrors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  alarm_description = "S3 4xx errors detected for bucket ${var.bucket_name}"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  dimensions = {
    BucketName = var.bucket_name
    FilterId   = "EntireBucket"
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_5xx" {
  count               = var.enable_s3_alarms ? 1 : 0
  alarm_name          = "${var.project}-${var.env}-s3-5xx-errors"
  namespace           = "AWS/S3"
  metric_name         = "5xxErrors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  alarm_description = "S3 5xx errors detected for bucket ${var.bucket_name}"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  dimensions = {
    BucketName = var.bucket_name
    FilterId   = "EntireBucket"
  }
}

############################################
# Redshift Serverless RPUUtilization alarm
############################################
resource "aws_cloudwatch_metric_alarm" "redshift_rpu_util" {
  count               = var.enable_redshift_alarm ? 1 : 0
  alarm_name          = "${var.project}-${var.env}-redshift-rpu-util"
  namespace           = "AWS/Redshift-Serverless"
  metric_name         = "RPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.redshift_rpu_threshold

  alarm_description = "Redshift Serverless RPUUtilization high for workgroup ${var.redshift_workgroup_name}"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  dimensions = {
    Workgroup = var.redshift_workgroup_name
  }
}

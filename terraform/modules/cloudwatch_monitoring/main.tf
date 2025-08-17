
# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project}-${var.env}-alerts"
  tags = var.tags
}

# Glue Job FAILED -> SNS

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

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "glue_job_failed_to_sns" {
  rule      = aws_cloudwatch_event_rule.glue_job_failed.name
  target_id = "GlueJobFailedToSNS"
  arn       = aws_sns_topic.alerts.arn
}


# S3 Error Alarms (Simplified)
resource "aws_cloudwatch_metric_alarm" "s3_4xx" {
  count               = var.enable_s3_alarms ? 1 : 0
  alarm_name          = "${var.project}-${var.env}-s3-4xx-errors"
  namespace           = "AWS/S3"
  metric_name         = "4xxErrors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 2
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 5

  alarm_description = "S3 4xx errors detected for bucket ${var.bucket_name}"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  dimensions = {
    BucketName = var.bucket_name
    FilterId   = "EntireBucket"
  }

  tags = var.tags
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

  tags = var.tags
}

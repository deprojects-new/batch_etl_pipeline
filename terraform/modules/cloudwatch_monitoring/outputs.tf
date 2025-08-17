output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "glue_failed_rule_name" {
  value = aws_cloudwatch_event_rule.glue_job_failed.name
}

output "s3_alarm_names" {
  value = compact([
    try(aws_cloudwatch_metric_alarm.s3_4xx[0].alarm_name, null),
    try(aws_cloudwatch_metric_alarm.s3_5xx[0].alarm_name, null),
  ])
}

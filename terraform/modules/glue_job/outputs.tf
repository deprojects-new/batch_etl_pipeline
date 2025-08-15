output "job_name" {
  value = aws_glue_job.job.name
}

output "script_s3_uri" {
  value = "s3://${var.bucket_name}/${aws_s3_object.glue_script.key}"
}

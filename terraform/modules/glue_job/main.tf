# Upload your local Glue script to S3 (ensures infra owns the artifact)
resource "aws_s3_object" "glue_script" {
  bucket  = var.bucket_name
  key     = var.script_s3_key
  content = file(var.script_local_path)
  etag    = filemd5(var.script_local_path)
}

resource "aws_glue_job" "job" {
  name     = var.job_name
  role_arn = var.glue_role_arn

  command {
    name            = "glueetl"
    python_version  = var.python_version
    script_location = "s3://${var.bucket_name}/${aws_s3_object.glue_script.key}"
  }

  glue_version      = "4.0"
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  execution_class   = "STANDARD" # or FLEX if you want cheaper/slow

  default_arguments = {
    "--job-language"   = "python"
    "--enable-metrics" = "true"
  }
}


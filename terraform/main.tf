module "s3_one_bucket" {
  source           = "./modules/s3_one_bucket"
  bucket_base_name = var.bucket_base_name
  project          = var.project
  env              = var.env
}

module "iam_roles" {
  source                    = "./modules/iam_roles"
  bucket_arn                = module.s3_one_bucket.bucket_arn
  bucket_raw_prefix_arn     = module.s3_one_bucket.raw_prefix_arn
  bucket_scripts_prefix_arn = module.s3_one_bucket.scripts_prefix_arn
}

module "glue_catalog" {
  source        = "./modules/glue_catalog"
  database_name = "${var.project}_${var.env}_db"
  s3_raw_path   = "s3://${module.s3_one_bucket.bucket}/${module.s3_one_bucket.raw_prefix}"
  glue_role_arn = module.iam_roles.glue_role_arn
}

module "glue_job" {
  source            = "./modules/glue_job"
  job_name          = var.glue_job_name
  glue_role_arn     = module.iam_roles.glue_role_arn
  bucket_name       = module.s3_one_bucket.bucket
  script_local_path = var.glue_script_local_path
  script_s3_key     = "${module.s3_one_bucket.scripts_prefix}etl_script.py"

  python_version    = var.glue_python_version
  worker_type       = var.glue_worker_type
  number_of_workers = var.glue_number_workers
}

module "redshift_serverless" {
  source             = "./modules/redshift_serverless"
  namespace_name     = var.redshift_namespace_name
  workgroup_name     = var.redshift_workgroup_name
  subnet_ids         = var.vpc_subnet_ids
  security_group_ids = var.vpc_security_group_ids

  # IAM role Redshift will assume for COPY from S3
  redshift_copy_role_arn = module.iam_roles.redshift_copy_role_arn
}

module "cloudwatch_monitoring" {
  source = "./modules/cloudwatch_monitoring"

  project = var.project
  env     = var.env

  glue_job_name = var.glue_job_name
  bucket_name   = module.s3_one_bucket.bucket

  redshift_workgroup_name = module.redshift_serverless.workgroup_name

  # Optional toggles/threshold
  enable_s3_alarms       = true
  enable_redshift_alarm  = true
  redshift_rpu_threshold = 80
}

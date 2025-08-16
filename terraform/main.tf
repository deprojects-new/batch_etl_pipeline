

module "data_lake_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.data_bucket_name
  tags        = var.tags
}

module "iam" {
  source           = "./modules/iam_roles"
  project          = var.project
  env              = var.env
  data_bucket_arn  = module.data_lake_bucket.bucket_arn
  data_bucket_name = module.data_lake_bucket.bucket_name
  tags             = local.tags
}

module "redshift" {
  source              = "./modules/redshift_cluster"
  cluster_identifier  = var.cluster_identifier
  db_name             = var.db_name
  master_username     = var.master_username
  master_password     = var.master_password
  node_type           = var.node_type
  number_of_nodes     = var.number_of_nodes
  port                = var.port
  subnet_ids          = var.subnet_ids
  vpc_id              = var.vpc_id
  allowed_cidr        = var.allowed_cidr
  kms_key_id          = var.kms_key_id
  publicly_accessible = var.publicly_accessible
  redshift_role_arn   = module.iam.redshift_role_arn
  tags                = local.tags
}

module "catalog" {
  source                  = "./modules/glue_catalog"
  catalog_db_name         = var.catalog_db_name
  enable_crawler          = var.enable_crawler
  crawler_name            = var.crawler_name
  crawler_s3_targets      = var.crawler_s3_targets
  glue_crawler_role_arn   = module.iam.glue_role_arn
  tags                    = local.tags
  glue_jobs               = var.glue_jobs
  tags                    =local.tags
}


locals {
  tags = merge(
    {
      Environment = var.env
      Project     = var.project
    },
    var.tags
  )
}
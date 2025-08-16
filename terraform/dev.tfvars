aws_region = "us-east-1"

# Data Lake Configuration
data_lake_bucket_name    = "assignment5-data-lake"
data_lake_versioning     = true
data_lake_lifecycle_days = 365

# Glue Configuration
glue_database_name = "batch_etl_db"
glue_crawler_name  = "batch-etl-crawler"
glue_job_name      = "batch-etl-job"

# Tags
env     = "dev"
project = "batch-etl-pipeline"

tags = {
  Owner       = "Jeeva"
  Environment = "dev"
  Project     = "batch-etl-pipeline"
}

# Users
users = ["Abhinav", "Priya", "Srinidhi"]

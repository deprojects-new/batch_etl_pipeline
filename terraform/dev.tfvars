aws_region = "us-east-1"

# Data Lake Configuration
data_lake_bucket_name = "assignment2-data-lake"
# data_lake_versioning = true      
# data_lake_lifecycle_days = 365  

feature/Jeevan
Updated upstream
# Glue Configuration
glue_database_name = "batch_etl_db"
glue_crawler_name  = "batch-etl-crawler"
glue_job_name      = "batch-etl-job"

# Glue Configuration - These are now handled in main.tf
# glue_database_name = "assignment2_data_catalog"  
# glue_crawler_name = "assignment2-crawler"        
# glue_job_name = "bronze-to-silver-etl"     
processed_bucket = "assignment2-data-lake"
processed_prefix = "processed/sales"


# Glue Configuration - These are now handled in main.tf
# glue_database_name = "assignment2_data_catalog"  
# glue_crawler_name = "assignment2-crawler"        
# glue_job_name = "bronze-to-silver-etl"          
main

# Tags
env     = "dev"
project = "assignment2"

tags = {
  Owner       = "Jeevan"
  Environment = "dev"
  Project     = "assignment2"
}

# Users
users = ["Abhinav", "Priya", "Srinidhi"]




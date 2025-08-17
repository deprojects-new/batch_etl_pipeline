aws_region = "us-east-1"

# Data Lake Configuration
data_lake_bucket_name = "assignment2-data-lake"
# data_lake_versioning = true      
# data_lake_lifecycle_days = 365  

# Glue Configuration - These are now handled in main.tf
# glue_database_name = "assignment2_data_catalog"  
# glue_crawler_name = "assignment2-crawler"        
# glue_job_name = "bronze-to-silver-etl"          

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




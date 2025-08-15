region  = "us-east-1"
project = "batch-etl-sales"
env     = "dev"

bucket_base_name = "batch-etl-sales"

glue_job_name          = "sales_etl_glue_job"
glue_script_local_path = "../src/glue_scripts/etl_script.py"

redshift_namespace_name = "sales_dev_ns"
redshift_workgroup_name = "sales_dev_wg"

# Replace with YOUR VPC resources
vpc_subnet_ids         = ["subnet-052fd72ab80ccb39c", "subnet-0ec6dc94592901c62"]
vpc_security_group_ids = ["sg-010cdd41fe817a672"]

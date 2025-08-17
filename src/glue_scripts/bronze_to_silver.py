import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext

# Get parameters
args = getResolvedOptions(sys.argv, ["JOB_NAME", "raw_path", "processed_path"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Read raw data from S3 (JSON format)
raw_df = spark.read.json(args["raw_path"])

# Basic cleaning (drop nulls, remove duplicates)
cleaned_df = raw_df.dropna().dropDuplicates()

# Write to silver zone (Parquet format)
(cleaned_df.write.mode("overwrite").format("parquet").save(args["processed_path"]))

print("✅ Bronze → Silver ETL complete")

job.commit()

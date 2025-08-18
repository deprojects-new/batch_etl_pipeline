import sys
<<<<<<< Updated upstream

=======
import datetime
import boto3
import uuid
>>>>>>> Stashed changes
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
<<<<<<< Updated upstream

# Get parameters
args = getResolvedOptions(sys.argv, ["JOB_NAME", "raw_path", "processed_path"])
=======
import subprocess

def filename_to_epoch(key: str) -> int:
    # Example key: bronze/sales_20250818_021930.json
    filename = key.split("/")[-1]
    timestamp_str = filename.replace("sales_", "").replace(".json", "")
    date_str, time_str = timestamp_str.split("_")  # 20250818, 021930
    year = int(date_str[0:4]); month = int(date_str[4:6]); day = int(date_str[6:8])
    hour = int(time_str[0:2]); minute = int(time_str[2:4]); second = int(time_str[4:6])
    dt = datetime.datetime(year, month, day, hour, minute, second, tzinfo=datetime.timezone.utc)
    return int(dt.timestamp()), timestamp_str  # return both epoch + timestamp string

# -----------------------------
# Glue Setup
# -----------------------------
args = getResolvedOptions(sys.argv, ["JOB_NAME", "bronze_s3_path", "silver_s3_path","bronze_database","silver_database"])
>>>>>>> Stashed changes

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

<<<<<<< Updated upstream
# Read raw data from S3 (JSON format)
raw_df = spark.read.json(args["raw_path"])

# Basic cleaning (drop nulls, remove duplicates)
cleaned_df = raw_df.dropna().dropDuplicates()

# Write to silver zone (Parquet format)
(cleaned_df.write.mode("append").format("parquet").save(args["processed_path"]))

print("✅ Bronze → Silver ETL complete")
=======
# -----------------------------
# Locate latest JSON file
# -----------------------------
raw_path = args["bronze_s3_path"]
if raw_path.endswith("/"):
    raw_path = raw_path[:-1]

bucket = raw_path.replace("s3://", "").split("/")[0]
prefix = "/".join(raw_path.replace("s3://", "").split("/")[1:])

s3 = boto3.client("s3")
paginator = s3.get_paginator("list_objects_v2")
pages = paginator.paginate(Bucket=bucket, Prefix=prefix)

json_files = []
for page in pages:
    if "Contents" in page:
        for obj in page["Contents"]:
            key = obj["Key"]
            if key.endswith(".json") and "sales_" in key:
                json_files.append(key)

if not json_files:
    raise Exception(f"No sales_*.json files found in {args['bronze_s3_path']}")

# Pick latest JSON by filename timestamp
latest_key = max(json_files, key=lambda k: filename_to_epoch(k)[0])
_, timestamp_str = filename_to_epoch(latest_key)
latest_path = f"s3://{bucket}/{latest_key}"

print("✅ Latest JSON file:", latest_path)

# -----------------------------
# Transform JSON → Parquet
# -----------------------------
raw_df = spark.read.json(latest_path)
cleaned_df = raw_df.dropna().dropDuplicates()

# -----------------------------
# Write Parquet with timestamp in filename
# -----------------------------
tmp_output = f"{args['silver_s3_path']}/_tmp_{uuid.uuid4()}"
final_output = f"{args['silver_s3_path']}/sales_{timestamp_str}.parquet"

cleaned_df.coalesce(1).write.mode("overwrite").parquet(tmp_output)

# Move part file → sales_<timestamp>.parquet
subprocess.run([
    "aws", "s3", "mv",
    f"{tmp_output}/part-*.parquet",
    final_output
], check=True)

# Clean up
subprocess.run(["aws", "s3", "rm", "--recursive", tmp_output], check=True)

print("✅ Bronze → Silver ETL complete. File saved at:", final_output)
>>>>>>> Stashed changes

job.commit()

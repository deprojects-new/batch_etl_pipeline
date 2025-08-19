import sys
import boto3
import datetime
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import col, sum, count, avg, max, min

# -----------------------------
# Arguments
# -----------------------------
args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "bucket",
        "batch_id"
    ],
)

# -----------------------------
# Glue Setup
# -----------------------------
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# -----------------------------
# Construct S3 paths
# -----------------------------
bucket = args["bucket"]
batch_id = args["batch_id"]
silver_path = f"s3://{bucket}/silver/sales"
gold_path = f"s3://{bucket}/gold"

print(f"Processing Silver data from: {silver_path}")
print(f"Batch ID: {batch_id}")

# -----------------------------
# Read from Silver Zone
# -----------------------------
silver_df = spark.read.parquet(silver_path)

# Basic cleaning
silver_df = silver_df.na.drop(how='all')  # Remove completely null rows
silver_df = silver_df.dropDuplicates()    # Remove duplicates

# Filter by batch_id if it exists
if "batch_id" in silver_df.columns:
    silver_df = silver_df.filter(col("batch_id") == batch_id)

print(f"Processing {silver_df.count()} rows")

# -----------------------------
# Show Silver Data Structure
# -----------------------------
print("=== SILVER DATA STRUCTURE ===")
print(f"Columns: {silver_df.columns}")
print(f"Total rows: {silver_df.count()}")

# Show sample data
print("\n=== SAMPLE DATA ===")
silver_df.show(5, truncate=False)

# Show data types
print("\n=== DATA TYPES ===")
silver_df.printSchema()

# -----------------------------
# Create Simple Aggregations
# -----------------------------
print("\n=== CREATING SIMPLE AGGREGATIONS ===")

# 1. Daily Sales Summary
if "sale_date" in silver_df.columns or "date" in silver_df.columns:
    date_col = "sale_date" if "sale_date" in silver_df.columns else "date"
    
    daily_sales = silver_df.groupBy(date_col).agg(
        count("*").alias("total_transactions"),
        sum("total_amount").alias("total_revenue"),
        avg("total_amount").alias("avg_transaction_value"),
        count("customer_id").alias("unique_customers")
    )
    
    print(f"Created daily sales summary: {daily_sales.count()} rows")
    daily_sales.write.mode("overwrite").parquet(f"{gold_path}/daily_sales_summary")

# 2. Product Performance
if "product_id" in silver_df.columns and "product_name" in silver_df.columns:
    product_performance = silver_df.groupBy("product_id", "product_name").agg(
        count("*").alias("units_sold"),
        sum("total_amount").alias("total_revenue"),
        avg("unit_price").alias("avg_unit_price")
    )
    
    print(f"Created product performance: {product_performance.count()} rows")
    product_performance.write.mode("overwrite").parquet(f"{gold_path}/product_performance")

# 3. Store Performance
if "store_id" in silver_df.columns and "store_name" in silver_df.columns:
    store_performance = silver_df.groupBy("store_id", "store_name").agg(
        count("*").alias("total_transactions"),
        sum("total_amount").alias("total_revenue"),
        count("customer_id").alias("unique_customers")
    )
    
    print(f"Created store performance: {store_performance.count()} rows")
    store_performance.write.mode("overwrite").parquet(f"{gold_path}/store_performance")

# 4. Customer Summary
if "customer_id" in silver_df.columns and "customer_name" in silver_df.columns:
    customer_summary = silver_df.groupBy("customer_id", "customer_name").agg(
        count("*").alias("total_purchases"),
        sum("total_amount").alias("total_spent"),
        avg("total_amount").alias("avg_purchase_value")
    )
    
    print(f"Created customer summary: {customer_summary.count()} rows")
    customer_summary.write.mode("overwrite").parquet(f"{gold_path}/customer_summary")

print(f"✅ Silver -> Gold ETL complete!")
print(f"   - Batch ID: {batch_id}")
print(f"   - Created simple aggregations in Gold layer")

job.commit()

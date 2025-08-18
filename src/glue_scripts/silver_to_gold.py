import sys
<<<<<<< Updated upstream

=======
import boto3
import datetime
>>>>>>> Stashed changes
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
<<<<<<< Updated upstream

=======
from pyspark.sql.functions import col, monotonically_increasing_id, year, month, dayofmonth, dayofweek

# -----------------------------
# Helper function to parse timestamp from parquet filename
# -----------------------------
def filename_to_epoch(key: str) -> int:
    # Example: silver/sales_20250818_021930.parquet
    filename = key.split("/")[-1]
    timestamp_str = filename.replace("sales_", "").replace(".parquet", "")
    date_str, time_str = timestamp_str.split("_")
    year_, month_, day_ = int(date_str[0:4]), int(date_str[4:6]), int(date_str[6:8])
    hour, minute, second = int(time_str[0:2]), int(time_str[2:4]), int(time_str[4:6])
    dt = datetime.datetime(year_, month_, day_, hour, minute, second, tzinfo=datetime.timezone.utc)
    return int(dt.timestamp())

# -----------------------------
# Arguments
# -----------------------------
>>>>>>> Stashed changes
args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
<<<<<<< Updated upstream
        "silver_path",
        "gold_path",
        "redshift_jdbc_url",
        "redshift_user",
        "redshift_pass",
        "redshift_table",
    ],
)

=======
        "silver_s3_path",
        "gold_s3_path",
        "silver_database",
        "gold_database"
    ],
)

# -----------------------------
# Glue Setup
# -----------------------------
>>>>>>> Stashed changes
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

<<<<<<< Updated upstream
# Read silver zone data
silver_df = spark.read.parquet(args["silver_path"])

# Example transformation: daily sales aggregation
from pyspark.sql.functions import col
from pyspark.sql.functions import sum as _sum

gold_df = silver_df.groupBy("event_type").agg(_sum(col("amount")).alias("total_amount"))

# Write gold data back to S3
(gold_df.write.mode("append").format("parquet").save(args["gold_path"]))

# Load into Redshift using JDBC
gold_df.write.format("jdbc").option("url", args["redshift_jdbc_url"]).option(
    "dbtable", args["redshift_table"]
).option("user", args["redshift_user"]).option("password", args["redshift_pass"]).mode(
    "append"
).save()

print("✅ Silver → Gold ETL + Redshift load complete")
=======
# -----------------------------
# Read from Silver Zone
# -----------------------------
bucket = args["silver_s3_path"].replace("s3://", "").split("/")[0]
prefix = "/".join(args["silver_s3_path"].replace("s3://", "").split("/")[1:])

s3 = boto3.client("s3")
resp = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)

parquet_files = [obj for obj in resp["Contents"] if obj["Key"].endswith(".parquet")]
if not parquet_files:
    raise Exception(f"No parquet files found in {args['silver_s3_path']}")

# Pick latest parquet by filename timestamp
latest_file = max(parquet_files, key=lambda x: filename_to_epoch(x["Key"]))["Key"]
latest_path = f"s3://{bucket}/{latest_file}"
print("✅ Latest Parquet file:", latest_path)

latest_df = spark.read.parquet(latest_path)

# -----------------------------
# Detect date column
# -----------------------------
date_col = None
if "date" in latest_df.columns:
    date_col = "date"
elif "timestamp" in latest_df.columns:
    date_col = "timestamp"
else:
    raise Exception("❌ No date/timestamp column found in Silver file!")

# -----------------------------
# Build Dimension Tables
# -----------------------------
# Date Dimension
dim_date = latest_df.select(
    col(date_col).alias("full_date")
).dropDuplicates()

dim_date = dim_date.withColumn("date_id", monotonically_increasing_id()) \
                   .withColumn("year", year(col("full_date"))) \
                   .withColumn("month", month(col("full_date"))) \
                   .withColumn("day", dayofmonth(col("full_date"))) \
                   .withColumn("weekday", dayofweek(col("full_date")))

# Store Dimension
dim_store = latest_df.select("store_id", "store_name", "city").dropDuplicates() \
    if all(c in latest_df.columns for c in ["store_id", "store_name", "city"]) else None

# Product Dimension
dim_product = latest_df.select("product_id", "product_name", "category", "unit_price").dropDuplicates() \
    if all(c in latest_df.columns for c in ["product_id", "product_name", "category", "unit_price"]) else None

# Customer Dimension
dim_customer = latest_df.select("customer_id", "customer_name").dropDuplicates() \
    if all(c in latest_df.columns for c in ["customer_id", "customer_name"]) else None

# Payment Method Dimension
if "payment_method" in latest_df.columns:
    dim_payment = latest_df.select("payment_method").dropDuplicates() \
        .withColumn("payment_method_id", monotonically_increasing_id())
else:
    dim_payment = None

# -----------------------------
# Build Fact Table
# -----------------------------
fact_sales = latest_df.join(dim_date, latest_df[date_col] == dim_date.full_date, "left")

if dim_store is not None:
    fact_sales = fact_sales.join(dim_store, "store_id", "left")
if dim_product is not None:
    fact_sales = fact_sales.join(dim_product, "product_id", "left")
if dim_customer is not None:
    fact_sales = fact_sales.join(dim_customer, "customer_id", "left")
if dim_payment is not None:
    fact_sales = fact_sales.join(dim_payment, "payment_method", "left")

# Keep only available columns
fact_cols = [
    "transaction_id",
    "date_id",
    "store_id" if "store_id" in fact_sales.columns else None,
    "product_id" if "product_id" in fact_sales.columns else None,
    "customer_id" if "customer_id" in fact_sales.columns else None,
    "payment_method_id" if "payment_method_id" in fact_sales.columns else None,
    "quantity_sold" if "quantity_sold" in fact_sales.columns else None,
    "unit_price" if "unit_price" in fact_sales.columns else None,
    "total_amount" if "total_amount" in fact_sales.columns else None
]
fact_cols = [c for c in fact_cols if c is not None]
fact_sales = fact_sales.select(*fact_cols)

# -----------------------------
# Write to Gold Layer
# -----------------------------
# ✅ Partition only where it makes sense (DimDate + FactSales)
dim_date.write.mode("append").partitionBy("year", "month", "day") \
    .parquet(f"{args['gold_s3_path']}/DimDate")

if dim_store is not None:
    dim_store.write.mode("append").parquet(f"{args['gold_s3_path']}/DimStore")

if dim_product is not None:
    dim_product.write.mode("append").parquet(f"{args['gold_s3_path']}/DimProduct")

if dim_customer is not None:
    dim_customer.write.mode("append").parquet(f"{args['gold_s3_path']}/DimCustomer")

if dim_payment is not None:
    dim_payment.write.mode("append").parquet(f"{args['gold_s3_path']}/DimPaymentMethod")

fact_sales.write.mode("append").partitionBy(date_col).parquet(f"{args['gold_s3_path']}/FactSales")

print("✅ Silver → Gold ETL complete. Partitioned by sales date:", date_col)
>>>>>>> Stashed changes

job.commit()

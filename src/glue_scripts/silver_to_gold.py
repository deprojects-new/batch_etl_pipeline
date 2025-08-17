import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext

args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "silver_path",
        "gold_path",
        "redshift_jdbc_url",
        "redshift_user",
        "redshift_pass",
        "redshift_table",
    ],
)

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Read silver zone data
silver_df = spark.read.parquet(args["silver_path"])

# Example transformation: daily sales aggregation
from pyspark.sql.functions import col
from pyspark.sql.functions import sum as _sum

gold_df = silver_df.groupBy("event_type").agg(_sum(col("amount")).alias("total_amount"))

# Write gold data back to S3
(gold_df.write.mode("overwrite").format("parquet").save(args["gold_path"]))

# Load into Redshift using JDBC
gold_df.write.format("jdbc").option("url", args["redshift_jdbc_url"]).option(
    "dbtable", args["redshift_table"]
).option("user", args["redshift_user"]).option("password", args["redshift_pass"]).mode(
    "overwrite"
).save()

print("✅ Silver → Gold ETL + Redshift load complete")

job.commit()

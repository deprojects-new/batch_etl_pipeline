from datetime import datetime, timedelta
from airflow import DAG
from airflow.decorators import task
from airflow.exceptions import AirflowSkipException
from airflow.operators.empty import EmptyOperator
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.amazon.aws.operators.glue_crawler import GlueCrawlerOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
# from airflow.sensors.python import PythonSensor  # Not used anymore

from common.constants import (
	BUCKET, GLUE_JOB_B2S, GLUE_JOB_S2G, CRAWLER_SILVER,
	REDSHIFT_IAM_ROLE_ARN
)
from common.helpers import (
	now_batch_id, bronze_prefix, gold_sales_prefix,
	mark_processed, is_processed
)

default_args = {
	"owner": "data-eng",
	"retries": 2,
	"retry_delay": timedelta(minutes=5),
}

with DAG(
	dag_id="medallion_batch_etl",
	description="Bronze -> Silver -> Gold -> Redshift (clean, batch_id-scoped)",
	start_date=datetime(2025,1,1),
	schedule_interval=None,
	catchup=False,
	default_args=default_args,
	max_active_runs=1,
	tags=["medallion","etl","batch"],
) as dag:

	start = EmptyOperator(task_id="start")
	end   = EmptyOperator(task_id="end")

	@task
	def determine_batch(**context) -> dict:
		bid = (context.get("dag_run") and context["dag_run"].conf.get("batch_id")) or now_batch_id()
		if is_processed(bid):
			raise AirflowSkipException(f"Batch {bid} already processed.")
		return {
			"batch_id": bid,
			"bronze_prefix": bronze_prefix(bid),
			"gold_sales_prefix": gold_sales_prefix(bid),
		}

	@task
	def local_generate(**context):
		batch = context['ti'].xcom_pull(task_ids='determine_batch')
		if not batch:
			raise ValueError("No batch data received from determine_batch task")
		
		try:
			from src.ingestion.upload_to_s3 import generate_and_upload_batch
		except Exception:
			from ingestion.upload_to_s3 import generate_and_upload_batch
		generate_and_upload_batch(
			bucket=BUCKET,
			batch_id=batch["batch_id"],
			base_prefix="bronze/sales/",
			target_size_mb=64,
			chunk_size_mb=16,
		)

	# No marker needed - ETL scripts work directly with batch scoping

	bronze_to_silver = GlueJobOperator(
		task_id="bronze_to_silver",
		job_name=GLUE_JOB_B2S,
		script_args={
			"--bucket": BUCKET,
			"--bronze_prefix": "{{ ti.xcom_pull('determine_batch')['bronze_prefix'] }}",
		},
		aws_conn_id="aws_default",
		wait_for_completion=True,
		execution_timeout=timedelta(hours=1),
		retry_exponential_backoff=True,
	)

	crawl_silver = GlueCrawlerOperator(
		task_id="crawl_silver",
		config={"Name": CRAWLER_SILVER},
		aws_conn_id="aws_default",
		wait_for_completion=True,
		execution_timeout=timedelta(minutes=45),
		retry_exponential_backoff=True,
	)

	silver_to_gold = GlueJobOperator(
		task_id="silver_to_gold",
		job_name=GLUE_JOB_S2G,
		script_args={
			"--bucket": BUCKET,
			"--batch_id": "{{ ti.xcom_pull('determine_batch')['batch_id'] }}",
		},
		aws_conn_id="aws_default",
		wait_for_completion=True,
		execution_timeout=timedelta(hours=1),
		retry_exponential_backoff=True,
	)

	@task
	def setup_redshift_tables():
		"""Create or update Redshift tables with the correct schema."""
		sql_path = '/opt/airflow/sql/ddl_redshift.sql'
		with open(sql_path, 'r') as f:
			ddl_sql = f.read()
		hook = PostgresHook(postgres_conn_id='redshift_default')
		hook.run(ddl_sql)
		return "Redshift tables setup completed"

	@task(priority_weight=8)
	def load_to_redshift(**context):
		"""Simple TRUNCATE + COPY load"""
		sql_path = '/opt/airflow/sql/copy_to_redshift.sql'
		with open(sql_path, 'r') as f:
			sql_template = f.read()
		# Substitute runtime values without exposing ARNs in the SQL file
		sql = sql_template.replace('%(s3_bucket)s', BUCKET)
		if REDSHIFT_IAM_ROLE_ARN:
			sql = sql.replace('%(iam_role)s', REDSHIFT_IAM_ROLE_ARN)
		hook = PostgresHook(postgres_conn_id='redshift_default')
		hook.run(sql)
		return "Redshift load completed"

	@task
	def dq_checks():
		"""Simple DQ check: verify that Gold layer has data"""
		import boto3
		from botocore.config import Config
		
		s3 = boto3.client("s3", config=Config(retries={"max_attempts": 3}))
		
		# Check if any of our aggregation files exist
		gold_paths = [
			"gold/daily_sales_summary",
			"gold/product_performance", 
			"gold/store_performance",
			"gold/customer_summary"
		]
		
		for path in gold_paths:
			try:
				response = s3.list_objects_v2(Bucket=BUCKET, Prefix=path, MaxKeys=1)
				if response.get("KeyCount", 0) > 0:
					print(f"✅ Found data in {path}")
					return True
			except Exception as e:
				print(f"Warning: Error checking {path}: {e}")
				continue
		
		raise ValueError(f"DQ failed: no data found in Gold layer")

	@task
	def dq_checks_content():
		"""Simple DQ check: verify that Gold layer has valid parquet files"""
		import boto3
		from botocore.config import Config
		
		s3 = boto3.client("s3", config=Config(retries={"max_attempts": 3}))
		
		# Check if any of our aggregation files have valid parquet data
		gold_paths = [
			"gold/daily_sales_summary",
			"gold/product_performance", 
			"gold/store_performance",
			"gold/customer_summary"
		]
		
		for path in gold_paths:
			try:
				response = s3.list_objects_v2(Bucket=BUCKET, Prefix=path)
				for obj in response.get("Contents", []):
					key = obj["Key"]
					size = obj.get("Size", 0)
					if key.lower().endswith(".parquet") and size > 0:
						print(f"✅ Found valid parquet file: {key} (size: {size} bytes)")
						return True
			except Exception as e:
				print(f"Warning: Error checking {path}: {e}")
				continue
		
		raise ValueError(f"DQ failed: no valid parquet files found in Gold layer")

	@task
	def finalize(**context):
		batch = context['ti'].xcom_pull(task_ids='determine_batch')
		if not batch:
			raise ValueError("No batch data received from determine_batch task")
		mark_processed(batch["batch_id"])

	# Define task dependencies
	batch = determine_batch()
	start >> batch
	batch >> local_generate() >> bronze_to_silver >> crawl_silver >> silver_to_gold
	silver_to_gold >> dq_checks() >> dq_checks_content() >> setup_redshift_tables() >> load_to_redshift() >> finalize() >> end

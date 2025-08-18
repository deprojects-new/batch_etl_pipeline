# This .py is to check connectivity if aws creds are working and network is strong

from airflow import DAG
from datetime import datetime
from airflow.decorators import task
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

BUCKET = "assignment5-data-lake"
DB = "dev"

with DAG(
    dag_id="demo_connectivity",
    start_date=datetime(2025,1,1),
    schedule_interval=None,
    catchup=False,
    tags=["sanity"],
) as dag:

    @task
    def s3_write_read():
        s3 = S3Hook()
        key = "sandbox/hello.txt"
        s3.load_string("hello-from-airflow", key=key, bucket_name=BUCKET, replace=True)
        assert s3.check_for_key(key, bucket_name=BUCKET)

    s3_write_read()

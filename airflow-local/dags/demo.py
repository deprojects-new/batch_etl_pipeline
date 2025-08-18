from airflow import DAG
from airflow.decorators import task
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from datetime import datetime

BUCKET = "assignment5-data-lake"
BRONZE_PREFIX = "bronze/"
PROCESSED_PREFIX = "manifests/processed/"

def list_success(hook):
    keys = hook.list_keys(BUCKET, prefix=BRONZE_PREFIX) or []
    return [k for k in keys if k.endswith("/_SUCCESS")]

def batch_id_from_prefix(prefix:str)->str:
    parts = prefix.split("batch_id=")
    if len(parts) < 2: return None
    return parts[1].split("/")[0]

with DAG(
    "demo_discovery",
    start_date=datetime(2025,1,1),
    schedule_interval=None,
    catchup=False,
) as dag:

    @task
    def discover():
        s3 = S3Hook()
        succ = list_success(s3)
        out = []
        for k in succ:
            bronze_prefix = k.rsplit("/",1)[0] + "/"
            bid = batch_id_from_prefix(bronze_prefix)
            if not bid: continue
            if not s3.check_for_key(f"{PROCESSED_PREFIX}{bid}", bucket_name=BUCKET):
                out.append({"batch_id":bid,"bronze_prefix":bronze_prefix})
        return out

    @task
    def mark_processed(item:dict):
        s3 = S3Hook()
        s3.load_bytes(b"", key=f"{PROCESSED_PREFIX}{item['batch_id']}", bucket_name=BUCKET, replace=False)

    items = discover()
    mark_processed.expand(item=items)

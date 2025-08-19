from datetime import datetime, timezone
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from .constants import BUCKET, BRONZE, GOLD

def now_batch_id() -> str:
    # UTC, minute precision: 2025-08-16-22-00
    return datetime.now(timezone.utc).strftime("%Y-%m-%d-%H-%M")

def bronze_prefix(batch_id: str) -> str:
    return f"{BRONZE}sales/batch_id={batch_id}/"

def gold_sales_prefix(batch_id: str) -> str:
    return f"{GOLD}sales/batch_id={batch_id}/"

def write_success_marker(prefix: str):
    # Completion marker at the batch root
    S3Hook().load_bytes(b"", bucket_name=BUCKET, key=f"{prefix}_SUCCESS", replace=True)

def has_success_marker(prefix: str) -> bool:
    return S3Hook().check_for_key(bucket_name=BUCKET, key=f"{prefix}_SUCCESS")

def mark_processed(batch_id: str):
    S3Hook().load_bytes(b"", bucket_name=BUCKET, key=f"manifests/processed/{batch_id}", replace=False)

def is_processed(batch_id: str) -> bool:
    return S3Hook().check_for_key(bucket_name=BUCKET, key=f"manifests/processed/{batch_id}")

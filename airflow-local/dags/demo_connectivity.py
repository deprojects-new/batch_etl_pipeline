import sys
from datetime import datetime
from airflow import DAG
from airflow.decorators import task
# Ensure both /opt/airflow and /opt/airflow/src are importable
if "/opt/airflow" not in sys.path:
    sys.path.append("/opt/airflow")
if "/opt/airflow/src" not in sys.path:
    sys.path.append("/opt/airflow/src")
try:
    from src.ingestion.upload_to_s3 import generate_and_upload_batch
except Exception:
    from ingestion.upload_to_s3 import generate_and_upload_batch

BUCKET = "assignment2-data-lake"

with DAG(
    dag_id="demo_generate",
    start_date=datetime(2025, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["sanity", "generator"],
) as dag:

    @task
    def generate_small_batch(batch_id: str | None = None):
        
        result = generate_and_upload_batch(
            bucket=BUCKET,
            batch_id=batch_id,          
            base_prefix="bronze/sales/",
            target_size_mb=64,          
            chunk_size_mb=16,           
            seed=123                    
        )
        
        return result

    generate_small_batch()

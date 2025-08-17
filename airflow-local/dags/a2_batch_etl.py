from datetime import datetime
from airflow import DAG
from common.defaults import DEFAULT_ARGS

with DAG(
    dag_id="a2_batch_etl",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2025, 1, 1),
    schedule_interval="0 6,18 * * *",   # twice daily
    catchup=False,
    tags=["a2","orchestration"],
) as dag:
    pass  # tasks added in later phases

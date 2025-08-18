import os, time, boto3, pathlib

REGION          = os.environ["AWS_REGION"]
CLUSTER_ID      = os.environ["REDSHIFT_CLUSTER_ID"]
DATABASE        = os.environ["REDSHIFT_DATABASE"]
SECRET_ARN      = os.environ["REDSHIFT_SECRET_ARN"]   # Secrets Manager ARN ({"username","password"})
SCHEMA          = os.environ.get("REDSHIFT_SCHEMA", "public")
TABLE           = os.environ["REDSHIFT_TABLE"]        # e.g., sales
S3_PATH         = os.environ["S3_PATH"]               # e.g., s3://bucket/processed/sales/
COPY_ROLE_ARN   = os.environ["COPY_ROLE_ARN"]         # IAM role attached to the Redshift cluster
FILE_FORMAT     = os.environ.get("FILE_FORMAT", "parquet").lower()  # parquet|csv

# optional tuning
DIST_STYLE      = os.environ.get("DIST_STYLE", "AUTO")
SORTKEY         = os.environ.get("SORTKEY", "")       # e.g., "SORTKEY(order_date)"
ENCODING_HINT   = os.environ.get("ENCODING_HINT", "AUTO")

redshift_data = boto3.client("redshift-data", region_name=REGION)

def run_sql(sql: str):
    resp = redshift_data.execute_statement(
        ClusterIdentifier=CLUSTER_ID,
        Database=DATABASE,
        SecretArn=SECRET_ARN,
        Sql=sql,
    )
    stmt_id = resp["Id"]
    while True:
        d = redshift_data.describe_statement(Id=stmt_id)
        s = d["Status"]
        if s in ("FINISHED", "FAILED", "ABORTED"):
            if s != "FINISHED":
                raise RuntimeError(f"SQL failed ({s}): {d.get('Error','')} \nSQL:\n{sql}")
            return
        time.sleep(1)

def ensure_table():
    ddl = f"""
    create schema if not exists {SCHEMA};

    create table if not exists {SCHEMA}.{TABLE} (
      order_id      varchar(50),
      order_date    timestamp,
      customer_id   varchar(50),
      product_id    varchar(50),
      quantity      int,
      price         decimal(10,2),
      total_amount  decimal(12,2)
    )
    encode {ENCODING_HINT}
    diststyle {DIST_STYLE}
    {SORTKEY if SORTKEY else ""};
    """
    run_sql(ddl)

def build_copy_sql() -> str:
    if FILE_FORMAT == "parquet":
        fmt, extra = "FORMAT AS PARQUET", ""
    else:
        fmt = "FORMAT AS CSV"
        extra = "IGNOREHEADER 1 TIMEFORMAT 'auto' DATEFORMAT 'auto' BLANKSASNULL EMPTYASNULL TRUNCATECOLUMNS"
    return f"""
    copy {SCHEMA}.{TABLE}
    from '{S3_PATH}'
    iam_role '{COPY_ROLE_ARN}'
    {fmt}
    {extra}
    region '{REGION}';
    """

def run_post_checks():
    # Optional: run your checks from src/redshift_load/post_load_checks.sql
    checks_path = pathlib.Path(__file__).with_name("post_load_checks.sql")
    if checks_path.exists():
        sql_text = checks_path.read_text(encoding="utf-8")
        # you can split on ; if you keep one statement per line
        for stmt in [s.strip() for s in sql_text.split(";") if s.strip()]:
            run_sql(stmt)

def main():
    ensure_table()
    run_sql(build_copy_sql())
    print("COPY complete.")
    run_post_checks()

if __name__ == "__main__":
    main()
    
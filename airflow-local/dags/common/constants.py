import os

BUCKET = os.getenv("S3_BUCKET")
BRONZE = os.getenv("BRONZE_PREFIX", "bronze/")
SILVER = os.getenv("SILVER_PREFIX", "silver/")
GOLD   = os.getenv("GOLD_PREFIX", "gold/")

# Support both short and long env var names
GLUE_JOB_B2S = (
    os.getenv("GLUE_JOB_B2S")
    or os.getenv("GLUE_JOB_BRONZE_TO_SILVER")
)
GLUE_JOB_S2G = (
    os.getenv("GLUE_JOB_S2G")
    or os.getenv("GLUE_JOB_SILVER_TO_GOLD")
)
CRAWLER_SILVER = os.getenv("GLUE_CRAWLER_SILVER")

REDSHIFT_IAM_ROLE_ARN = os.getenv("REDSHIFT_IAM_ROLE_ARN") or os.getenv("RS_COPY_IAM_ROLE_ARN")

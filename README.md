# batch_etl_pipeline
Assignment_2_batch_etl_pipeline

# Batch ETL Pipeline: Sales Data → Amazon Redshift

## Overview
This project implements a **batch ETL pipeline** that ingests sales data from Amazon S3, transforms it using **AWS Glue**, and loads the curated data into **Amazon Redshift Serverless** for analytics.  
The entire infrastructure is provisioned with **Terraform** — no manual console configuration.

---

## 🛠 Architecture
**Flow:**
1. **Data Storage (S3)**  
   Raw sales files are uploaded to `s3://<bucket>/raw/`.
2. **Data Cataloging (Glue Catalog)**  
   Glue Crawler scans raw data and updates schema in Glue Catalog.
3. **ETL Transformation (Glue Job)**  
   PySpark script reads raw data, applies transformations, writes curated output to `s3://<bucket>/curated/`.
4. **Data Loading (Redshift Serverless)**  
   Curated data is loaded into Redshift tables via `COPY` commands.
5. **Monitoring (CloudWatch)**  
   Alerts for Glue job failures, S3 errors, and Redshift high utilization.

---

## Project Structure

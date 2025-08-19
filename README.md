# Batch ETL Pipeline with Medallion Architecture

## Project Overview

This project implements a **medallion architecture** batch ETL pipeline for processing sales data, using AWS services and Apache Airflow for orchestration. The pipeline transforms raw sales data through three layers (Bronze → Silver → Gold) and loads the final results into Amazon Redshift for analytics.

## Architecture

### Medallion Architecture Layers

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Bronze Layer  │───▶│  Silver Layer   │───▶│   Gold Layer    │───▶│    Redshift     │
│   (Raw Data)    │    │ (Cleaned Data)  │    │(Business Logic) │    │  (Analytics)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │                       │
        ▼                       ▼                       ▼                       ▼
   S3 + Glue              S3 + Delta              S3 + Delta              Redshift
   Catalog                 Lake                   Lake                    Tables
```

### Data Flow

1. **Bronze Layer**: Raw sales data stored in S3 with Glue Catalog
2. **Silver Layer**: Cleaned, validated data in Delta Lake format
3. **Gold Layer**: Business logic applied, denormalized tables
4. **Redshift**: Final analytics tables for business intelligence

### Key Components

- **S3**: Data storage for all layers
- **AWS Glue**: ETL processing and data cataloging
- **Delta Lake**: ACID transactions and schema evolution
- **Amazon Redshift**: Data warehouse for analytics
- **Apache Airflow**: Pipeline orchestration
- **Terraform**: Infrastructure as Code



### Input Schema
```sql
transaction_id    VARCHAR(100)
date             DATE
store_id         VARCHAR(50)
store_name       VARCHAR(100)
city             VARCHAR(100)
product_id       VARCHAR(50)
product_name     VARCHAR(200)
category         VARCHAR(100)
customer_id      VARCHAR(50)
customer_name    VARCHAR(200)
quantity_sold    INTEGER
unit_price       DECIMAL(10,2)
total_amount     DECIMAL(15,2)
payment_method   VARCHAR(50)
```



## Infrastructure Setup

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Python 3.8+
- Docker and Docker Compose (for local Airflow)

### Deployment Steps

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd batch_etl_pipeline
   ```

2. **Configure Variables**
   ```bash
   # Create terraform.tfvars
   cp terraform/variables.tf.example terraform/terraform.tfvars
   
   # Edit terraform.tfvars with your values
   aws_region = "us-east-1"
   redshift_password = "your-secure-password"
   ingress_cidr = "your-ip-address/32"
   ```

3. **Deploy Infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

4. **Upload ETL Scripts**
   ```bash
   # Upload scripts to S3 (replace with your bucket name)
   aws s3 cp src/glue_scripts/ s3://batch-etl-pipeline-dev-data/scripts/ --recursive
   ```

5. **Start Airflow Locally**
   ```bash
   cd airflow-local
   docker-compose up -d
   ```

## Pipeline Execution

### Schedule
- **Frequency**: Every 4 hours (configurable)
- **Processing Time**: ~30-45 minutes for 10GB daily data
- **Orchestrator**: Apache Airflow

### ETL Jobs

1. **Bronze to Silver**
   - Data quality checks
   - Null value validation
   - Duplicate removal
   - Delta Lake format conversion

2. **Silver to Gold**
   - Business logic application
   - Aggregations and denormalization
   - Customer segmentation
   - Performance metrics calculation

3. **Gold to Redshift**
   - Parquet conversion
   - Redshift table creation
   - COPY command execution
   - Data validation

### Data Quality Checks

- **Completeness**: Null value detection
- **Accuracy**: Range validation (e.g., positive amounts)
- **Uniqueness**: Duplicate transaction detection
- **Consistency**: Cross-table referential integrity
- **Timeliness**: ETL timestamp tracking

## Monitoring and Observability

### CloudWatch Metrics
- Glue job success/failure rates
- Processing time and throughput
- Error rates and retry counts
- S3 storage utilization

### Logging
- Structured logging in all ETL jobs
- CloudWatch log groups for each component
- Error tracking and alerting

### Data Lineage
- Glue Data Catalog integration
- ETL timestamp tracking
- Data quality score tracking

## Performance Optimization

### Redshift Optimization
- **Distribution Keys**: Store-based distribution for sales data
- **Sort Keys**: Date-based sorting for time-series queries
- **Compression**: Automatic column compression
- **VACUUM**: Regular table maintenance

### Glue Optimization
- **Worker Type**: G.1X for cost-effective processing
- **Worker Count**: 2 workers for 10GB daily volume
- **Delta Lake**: Efficient incremental processing
- **Partitioning**: Date-based partitioning

### S3 Optimization
- **Lifecycle Policies**: Automatic data archival
- **Intelligent Tiering**: Cost optimization
- **Cross-Region Replication**: Disaster recovery

## Security

### IAM Roles and Policies
- **Least Privilege**: Minimal required permissions
- **Service Roles**: Dedicated roles for each service
- **Cross-Account Access**: Secure cross-service communication

### Data Encryption
- **S3**: Server-side encryption (SSE-S3)
- **Redshift**: Encryption at rest
- **Glue**: Encryption in transit

### Network Security
- **VPC**: Isolated network environment
- **Security Groups**: Restricted port access
- **Private Subnets**: Internal service communication

## Cost Optimization

### Resource Sizing
- **Redshift**: Single-node dc2.large for development
- **Glue**: G.1X workers with minimal count
- **S3**: Intelligent tiering and lifecycle policies

### Scheduling
- **Batch Processing**: 4-hour intervals to reduce costs
- **Resource Scaling**: Automatic scaling based on workload
- **Spot Instances**: Consider for non-critical workloads

## Troubleshooting

### Common Issues

1. **Glue Job Failures**
   - Check CloudWatch logs
   - Verify IAM permissions
   - Validate input data format

2. **Redshift Connection Issues**
   - Verify security group rules
   - Check cluster status
   - Validate credentials

3. **Data Quality Issues**
   - Review validation logs
   - Check source data integrity
   - Verify transformation logic

### Debug Commands

```bash
# Check Glue job status
aws glue get-job-runs --job-name bronze-to-silver-etl

# Verify Redshift connectivity
psql -h <cluster-endpoint> -U <username> -d <database>

# Check S3 data
aws s3 ls s3://bucket-name/bronze/ --recursive
```


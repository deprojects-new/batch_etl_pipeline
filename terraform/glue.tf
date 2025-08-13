resource "aws_glue_catalog_database" "this" {
  name = replace("${var.project}_${var.env}_db", "-", "_")
}


# Crawler over RAW sales data (expects s3://<raw>/sales/)
resource "aws_glue_crawler" "raw_sales" {
  name          = "${var.project}-${var.env}-raw-sales-crawler"
  role          = aws_iam_role.glue_exec.arn
  database_name = aws_glue_catalog_database.this.name


  s3_target {
    path = "s3://${aws_s3_bucket.raw.bucket}/sales/"
  }


  # For demo: on-demand; you can also schedule:
  # schedule = "cron(0/30 * * * ? *)"
}


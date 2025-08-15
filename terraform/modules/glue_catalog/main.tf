resource "aws_glue_catalog_database" "db" {
  name = var.database_name
}

# Optional but handy: crawl raw/ to infer tables
resource "aws_glue_crawler" "raw_crawler" {
  name          = "${var.database_name}-raw-crawler"
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.db.name

  s3_target {
    path = var.s3_raw_path
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }
}

variable "database_name" { type = string }
variable "s3_raw_path"   { type = string }
variable "glue_role_arn" { type = string }

resource "aws_glue_catalog_database" "db" {
  name = var.database_name
}

# Optional but handy: crawl raw/ to infer tables
resource "aws_glue_crawler" "raw_crawler" {
  name         = "${var.database_name}-raw-crawler"
  role         = var.glue_role_arn
  database_name = aws_glue_catalog_database.db.name

  s3_target {
    path = var.s3_raw_path
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }
}

output "database_name" { value = aws_glue_catalog_database.db.name }
output "crawler_name"  { value = aws_glue_crawler.raw_crawler.name }

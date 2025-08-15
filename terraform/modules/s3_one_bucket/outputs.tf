output "bucket"         { value = aws_s3_bucket.this.bucket }
output "bucket_arn"     { value = aws_s3_bucket.this.arn }

output "raw_prefix"     { value = aws_s3_object.raw_prefix.key }
output "curated_prefix" { value = aws_s3_object.curated_prefix.key }
output "scripts_prefix" { value = aws_s3_object.scripts_prefix.key }

output "raw_prefix_arn"     { value = "${aws_s3_bucket.this.arn}/${aws_s3_object.raw_prefix.key}*" }
output "scripts_prefix_arn" { value = "${aws_s3_bucket.this.arn}/${aws_s3_object.scripts_prefix.key}*" }

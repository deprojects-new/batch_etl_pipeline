data "aws_iam_policy_document" "glue_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["glue.amazonaws.com"] }
  }
}


resource "aws_iam_role" "glue_exec" {
  name               = "${var.project}-${var.env}-glue-exec"
  assume_role_policy = data.aws_iam_policy_document.glue_trust.json
}


resource "aws_iam_role_policy" "glue_access" {
  role = aws_iam_role.glue_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect="Allow", Action=["glue:*"], Resource="*" },
      { Effect="Allow", Action=["s3:*"], Resource=[
        "arn:aws:s3:::${aws_s3_bucket.raw.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.raw.bucket}/*"
      ]}
    ]
  })
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["ec2.amazonaws.com"] }
  }
}


resource "aws_iam_role" "dbx_role" {
  name               = "${var.project}-${var.env}-dbx-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}


resource "aws_iam_instance_profile" "dbx_ip" {
  name = "${var.project}-${var.env}-dbx-ip"
  role = aws_iam_role.dbx_role.name
}


resource "aws_iam_role_policy" "dbx_policy" {
  role = aws_iam_role.dbx_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect="Allow", Action=["s3:*"], Resource=[
        "arn:aws:s3:::${aws_s3_bucket.raw.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.curated.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.stage.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.raw.bucket}/*",
        "arn:aws:s3:::${aws_s3_bucket.curated.bucket}/*",
        "arn:aws:s3:::${aws_s3_bucket.stage.bucket}/*"
      ]},
      { Effect="Allow", Action=["glue:*"], Resource="*" }
    ]
  })
}

data "aws_iam_policy_document" "redshift_trust" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["redshift.amazonaws.com"] }
  }
}


resource "aws_iam_role" "redshift_copy" {
  name               = "${var.project}-${var.env}-redshift-copy"
  assume_role_policy = data.aws_iam_policy_document.redshift_trust.json
}


resource "aws_iam_role_policy_attachment" "rs_s3_ro" {
  role       = aws_iam_role.redshift_copy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

locals {
  name_suffix = random_id.sfx.hex
  name_base   = "${var.project}-${var.env}"


  raw_bucket     = "${local.name_base}-raw-${local.name_suffix}"
  curated_bucket = "${local.name_base}-curated-${local.name_suffix}"
  stage_bucket   = "${local.name_base}-stage-${local.name_suffix}"
}


resource "random_id" "sfx" { byte_length = 2 }

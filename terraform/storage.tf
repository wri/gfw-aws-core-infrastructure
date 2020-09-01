################
# Buckets
################


resource "aws_s3_bucket" "pipelines" {
  bucket = "gfw-pipelines${local.bucket_suffix}"
  acl    = "private"
  tags   = local.tags

  lifecycle_rule {
    id      = "geotrellis_logs"
    enabled = true

    prefix = "geotrellis/logs/"

    transition {
      days          = 30 # initially set to 3 days, but somehow this is no longer possible
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  lifecycle_rule {
    id      = "geotrellis_results"
    enabled = true

    prefix = "geotrellis/results/"

    transition {
      days          = 30            # initally set to 7 days but this is somehow no longer possible
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}


resource "aws_s3_bucket" "data-lake" {
  bucket        = "gfw-data-lake${local.bucket_suffix}"
  acl           = "private"
  tags          = local.tags
  request_payer = "BucketOwner"
}


# Test buckets only exist in DEV environment
# Use count argument to create condition
# https://dev.to/tbetous/how-to-make-conditionnal-resources-in-terraform-440n
resource "aws_s3_bucket" "pipelines-test" {
  bucket = "gfw-pipelines-test"
  acl    = "private"
  tags   = local.tags
  count  = var.environment == "dev" ? 1 : 0
}

resource "aws_s3_bucket" "data-lake-test" {
  bucket = "gfw-data-lake-test"
  acl    = "private"
  tags   = local.tags
  count  = var.environment == "dev" ? 1 : 0
}


##################
# Bucket policies
##################


data "template_file" "pipelines_bucket_policy" {
  template = file("${path.root}/policies/bucket_policy_public_read.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "data-lake_bucket_policy_public" {
  template = file("${path.root}/policies/bucket_policy_public_read.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.data-lake.arn
  }
}

data "template_file" "data-lake_bucket_policy_emr_production" {
  template = file("${path.root}/policies/bucket_policy_role_read.json.tpl")
  vars = {
    bucket_arn       = aws_s3_bucket.data-lake.arn
    aws_resource_arn = "arn:aws:iam::${var.production_account_number}:role/core-emr_profile"
  }
}

data "template_file" "data-lake_bucket_policy_emr_staging" {
  template = file("${path.root}/policies/bucket_policy_role_read.json.tpl")
  vars = {
    bucket_arn       = aws_s3_bucket.data-lake.arn
    aws_resource_arn = "arn:aws:iam::${var.staging_account_number}:role/core-emr_profile"
  }
}

data "template_file" "data-lake_bucket_policy_emr_dev" {
  template = file("${path.root}/policies/bucket_policy_role_read.json.tpl")
  vars = {
    bucket_arn       = aws_s3_bucket.data-lake.arn
    aws_resource_arn = "arn:aws:iam::${var.dev_account_number}:role/core-emr_profile"
  }
}

resource "aws_s3_bucket_policy" "pipelines" {
  bucket = aws_s3_bucket.pipelines.id
  policy = data.template_file.pipelines_bucket_policy.rendered
}

resource "aws_s3_bucket_policy" "data-lake" {
  bucket = aws_s3_bucket.data-lake.id
  policy = module.data-lake_policy.result_document
}


##################
# IAM policies
##################


data "template_file" "s3_write_pipelines" {
  template = file("${path.root}/policies/iam_policy_s3_write.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
    prefix     = ""
  }
}

data "template_file" "s3_write_data-lake" {
  template = file("${path.root}/policies/iam_policy_s3_write.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.data-lake.arn
    prefix     = ""
  }
}

data "template_file" "s3_write_raw_data-lake" {
  template = file("${path.root}/policies/iam_policy_s3_write.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.data-lake.arn
    prefix     = "*/raw/"
  }
}

resource "aws_iam_policy" "s3_write_pipelines" {
  name   = "${local.project}-s3_write_pipelines"
  policy = data.template_file.s3_write_pipelines.rendered
}

resource "aws_iam_policy" "s3_write_data-lake" {
  name   = "${local.project}-s3_write_data-lake"
  policy = data.template_file.s3_write_data-lake.rendered

}

resource "aws_iam_policy" "s3_write_raw_data-lake" {
  name   = "${local.project}-s3_write_raw_data-lake"
  policy = data.template_file.s3_write_raw_data-lake.rendered

}
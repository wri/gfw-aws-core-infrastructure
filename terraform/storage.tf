resource "aws_s3_bucket_policy" "pipelines" {
  bucket = aws_s3_bucket.pipelines.id
  policy = data.template_file.pipelines_bucket_policy.rendered
}

resource "aws_s3_bucket_policy" "data-lake" {
  bucket = aws_s3_bucket.data-lake.id
  policy = module.data-lake_policy.result_document
}

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
      days          = 30 # initally set to 7 days but this is somehow no longer possible
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

  //  lifecycle_rule {
  //    id      = "intelligent_tiering"
  //    enabled = true
  //
  //    tags = {
  //      "rule"      = "tiering"
  //    }
  //
  //    transition {
  //      days          = 1
  //      storage_class = "INTELLIGENT_TIERING"
  //    }
  //  }
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

resource "aws_s3_bucket_policy" "pipelines" {
  bucket = aws_s3_bucket.pipelines.id
  policy = data.template_file.pipelines_bucket_policy.rendered
}


//resource "aws_s3_bucket_policy" "tiles" {
//  bucket = aws_s3_bucket.tiles.id
//  policy = module.tiles_policy.result_document
//
//}

resource "aws_s3_bucket_policy" "data-lake" {
  bucket = aws_s3_bucket.data-lake.id
  policy = module.data-lake_policy.result_document
}

resource "aws_s3_bucket" "pipelines" {
  bucket = "gfw-pipelines${local.bucket_suffix}"
  acl    = "private"
  tags   = local.tags
}


resource "aws_s3_bucket" "data-lake" {
  bucket        = "gfw-data-lake${local.bucket_suffix}"
  acl           = "private"
  tags          = local.tags
  request_payer = "BucketOwner"

}
//
//resource "aws_s3_bucket" "tiles" {
//  bucket = "gfw-tiles${local.bucket_suffix}"
//  acl    = "private"
//  tags   = local.tags
//
//  cors_rule {
//    allowed_headers = [
//      "Authorization",
//    ]
//    allowed_methods = [
//      "GET",
//    ]
//    allowed_origins = [
//      "*",
//    ]
//    expose_headers  = []
//    max_age_seconds = 3000
//  }
//  website {
//    index_document = "index.html"
//    routing_rules = jsonencode(
//      [
//        {
//          Condition = {
//            KeyPrefixEquals = "wdpa_protected_areas/latest/"
//          }
//          Redirect = {
//            HostName             = "tiles.globalforestwatch.org"
//            ReplaceKeyPrefixWith = "wdpa_protected_areas/v201909/"
//          }
//        },
//      ]
//    )
//  }
//}

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
//
//resource "aws_s3_bucket" "tiles-test" {
//  bucket = "gfw-tiles-test"
//  acl    = "private"
//  tags   = local.tags
//  count  = var.environment == "dev" ? 1 : 0
//}

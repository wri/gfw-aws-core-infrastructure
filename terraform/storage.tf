data "template_file" "pipelines_bucket_policy" {
  template = file("policies/s3_public.json")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}


resource "aws_s3_bucket" "pipelines" {
  bucket = "gfw-pipelines${local.bucket_suffix}"
  acl    = "private"
  tags   = local.tags
}

resource "aws_s3_bucket_policy" "pipelines" {
  bucket = aws_s3_bucket.pipelines.id
  policy = data.template_file.pipelines_bucket_policy.rendered
}


resource "aws_s3_bucket" "data-lake" {
  bucket = "gfw-data-lake${local.bucket_suffix}"
  acl    = "private"
  tags   = local.tags
}

resource "aws_s3_bucket" "tiles" {
  bucket = "gfw-tiles${local.bucket_suffix}"
  acl    = "private"
  tags   = local.tags
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

resource "aws_s3_bucket" "tiles-test" {
  bucket = "gfw-tiles-test"
  acl    = "private"
  tags   = local.tags
  count  = var.environment == "dev" ? 1 : 0
}

data "aws_caller_identity" "current" {}


data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "template_file" "pipelines_bucket_policy" {
  template = file("${path.root}/policies/s3_public.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "tiles_bucket_policy_public" {
  template = file("${path.root}/policies/s3_public.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.tiles.arn
  }
}

data "template_file" "tiles_bucket_policy_cloudfront" {
  template = file("${path.root}/policies/s3_aws.json.tpl")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = module.tile_cache.cloudfront_origin_access_identity_iam_arn
  }
}

data "template_file" "tiles_bucket_policy_lambda" {
  template = file("${path.root}/policies/s3_aws.json.tpl")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = module.tile_cache.lambda_edge_cloudfront_arn
  }
}

data "template_file" "s3_write_pipelines" {
  template = file("${path.root}/policies/s3_write_bucket.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "s3_write_tiles" {
  template = file("${path.root}/policies/s3_write_bucket.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.tiles.arn
  }
}

data "template_file" "s3_write_data-lake" {
  template = file("${path.root}/policies/s3_write_bucket.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.data-lake.arn
  }
}

data "template_file" "secrets_read_gfw-api-token" {
  template = file("${path.root}/policies/secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.gfw_api_token.arn
  }
}

data "template_file" "secrets_read_slack-data-updates-hook" {
  template = file("${path.root}/policies/secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.slack_gfw_sync.arn
  }
}

data "template_file" "trust_emr" {
  template = file("${path.root}/policies/trust_service.json.tpl")
  vars = {
    service = "elasticmapreduce"
  }
}

data "template_file" "trust_ec2" {
  template = file("${path.root}/policies/trust_service.json.tpl")
  vars = {
    service = "ec2"
  }
}

data "local_file" "emr_default_policy" {
  filename = "${path.root}/policies/emr_default.json"
}

data "local_file" "emr_ec2_default_policy" {
  filename = "${path.root}/policies/emr_ec2_default.json"
}

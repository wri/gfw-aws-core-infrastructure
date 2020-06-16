data "aws_caller_identity" "current" {}


data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm*"]
  }
}

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

data "template_file" "s3_write_pipelines" {
  template = file("${path.root}/policies/iam_policy_s3_write.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}


data "template_file" "s3_write_data-lake" {
  template = file("${path.root}/policies/iam_policy_s3_write.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.data-lake.arn
  }
}

data "template_file" "secrets_read_gfw-api-token" {
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.gfw_api_token.arn
  }
}

data "template_file" "secrets_read_slack-gfw-sync" {
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
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

data "template_file" "pipelines_bucket_policy" {
  template = file("policies/s3_public.json")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "tiles_bucket_policy_public" {
  template = file("policies/s3_public.json")
  vars = {
    bucket_arn = aws_s3_bucket.tiles.arn
  }
}

data "template_file" "tiles_bucket_policy_cloudfront" {
  template = file("policies/s3_aws.json")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = aws_cloudfront_origin_access_identity.tiles.iam_arn
  }
}

data "template_file" "tiles_bucket_policy_lambda" {
  template = file("policies/s3_aws.json")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = module.tile_cache.lambda_edge_cloudfront_arn
  }
}

data "local_file" "mount_nvme1n1_mime" {
  filename = "user_data/mount_nvme1n1_mime.sh"
}

data "aws_caller_identity" "current" {}


data "aws_ami" "latest-amazon-ecs-optimized" {

  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}




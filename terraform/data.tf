data "template_file" "pipelines_bucket_policy" {
  template = file("${path.module}/policies/s3_public.json")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "tiles_bucket_policy_public" {
  template = file("${path.module}/policies/s3_public.json")
  vars = {
    bucket_arn = aws_s3_bucket.tiles.arn
  }
}

data "template_file" "tiles_bucket_policy_cloudfront" {
  template = file("${path.module}/policies/s3_aws.json")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = aws_cloudfront_origin_access_identity.tiles.iam_arn
  }
}

data "template_file" "tiles_bucket_policy_lambda" {
  template = file("${path.module}/policies/s3_aws.json")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = module.tile_cache.lambda_edge_cloudfront_arn
  }
}

data "template_file" "s3_write_pipelines" {
  template = file("${path.root}/policies/s3_write_bucket.json")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "s3_write_data-lake" {
  template = file("${path.root}/policies/s3_write_bucket.json")
  vars = {
    bucket_arn = aws_s3_bucket.data-lake.arn
  }
}

data "template_file" "s3_write_tiles" {
  template = file("${path.root}/policies/s3_write_bucket.json")
  vars = {
    bucket_arn = aws_s3_bucket.tiles.arn
  }
}

data "template_file" "secrets_read_gfw-api-token" {
  template = file("${path.root}/policies/secrets_read.json")
  vars = {
    secret_arn = aws_secretsmanager_secret.gfw_api_token.arn
  }
}

//data "template_file" "ssh_keys_ec2_user" {
//  template = file("${path.module}/user_data/add_ssh_keys.sh")
//  vars = {
//    user         = "ec2-user",
//    public_key_1 = aws_key_pair.tmaschler_gfw.public_key,
//    public_key_2 = aws_key_pair.jterry_gfw.public_key
//  }
//}
//
//data "template_file" "ssh_keys_ubuntu" {
//  template = file("${path.module}/user_data/add_ssh_keys.sh")
//  vars = {
//    user         = "ubuntu",
//    public_key_1 = aws_key_pair.tmaschler_gfw.public_key,
//    public_key_2 = aws_key_pair.jterry_gfw.public_key
//  }
//}

data "local_file" "mount_nvme1n1_mime" {
  filename = "${path.module}/user_data/mount_nvme1n1_mime.sh"
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


data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "local_file" "emr_assume" {
  filename = "${path.root}/policies/emr_assume.json"
}

data "local_file" "ec2_assume" {
  filename = "${path.root}/policies/ec2_assume.json"
}

data "local_file" "emr_default_policy" {
  filename = "${path.root}/policies/emr_default.json"
}

data "local_file" "emr_ec2_default_policy" {
  filename = "${path.root}/policies/emr_ec2_default.json"
}

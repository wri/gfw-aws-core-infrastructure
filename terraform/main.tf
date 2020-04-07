# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
  backend "s3" {
    region         = "us-east-1"
    key            = "core.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.54.0"
}

# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source               = "./modules/bootstrap"
  s3_bucket            = local.tf_state_bucket
  dynamo_db_table_name = var.dynamo_db_lock_table_name
  tags                 = local.tags
}

module "lambda_layers" {
  source    = "./modules/lambda_layers"
  s3_bucket = local.tf_state_bucket
  project   = local.project
}

module "tile_cache" {
  source             = "./modules/tile_cache"
  project            = local.project
  tags               = local.tags
  environment        = var.environment
  certificate_arn    = var.environment == "production" ? aws_acm_certificate.globalforestwatch[0].arn : null
  bucket_domain_name = aws_s3_bucket.tiles.bucket_domain_name
  website_endpoint   = aws_s3_bucket.tiles.website_endpoint

}

module "tiles_policy" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-policy-document-aggregator.git?ref=0.2.0"
  source_documents = [
    data.template_file.tiles_bucket_policy_public.rendered,
    data.template_file.tiles_bucket_policy_cloudfront.rendered,
    data.template_file.tiles_bucket_policy_lambda.rendered
  ]
}

module "data-lakle_policy" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-policy-document-aggregator.git?ref=0.2.0"
  source_documents = [
    data.template_file.data-lake_bucket_policy_public.rendered,
    data.template_file.data-lake_bucket_policy_emr_production.rendered,
    data.template_file.data-lake_bucket_policy_emr_staging.rendered,
    data.template_file.data-lake_bucket_policy_emr_dev.rendered
  ]
}


module "vpc" {
  source             = "./modules/vpc"
  environment        = var.environment
  region             = var.aws_region
  key_name           = aws_key_pair.tmaschler_gfw.key_name
  bastion_ami        = data.aws_ami.amazon_linux_ami.id
  project            = local.project
  tags               = local.tags
  security_group_ids = [aws_security_group.default.id]
  //  user_data = data.template_file.ssh_keys_ec2_user.rendered
  cluster-name = var.cluster-name
}



################

data "aws_eks_cluster" "cluster" {
  name = module.k8s-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.k8s-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "k8s-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster-name
  cluster_version = "1.15"
  subnets         = module.vpc.public_subnet_ids
  vpc_id          = module.vpc.id

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 2
    }
  ]
}

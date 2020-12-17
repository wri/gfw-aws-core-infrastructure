locals {
  requester_payer = var.requester_pays == true ? "Requester" : "BucketOwner"
  acl             = var.public == true ? "public" : "private"
}

# Minimal implementation inspired by
# https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/blob/master/main.tf
resource "aws_s3_bucket" "default" {
  bucket        = var.bucket_name
  acl           = local.acl
  tags          = var.tags
  request_payer = local.requester_payer

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      id      = lifecycle_rule.value["id"]
      enabled = lifecycle_rule.value["enabled"]
      prefix  = lifecycle_rule.value["prefix"]

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

    }
  }
}

#################
# Bucket policies
#################

resource "aws_s3_bucket_policy" "default" {
  count = length(var.public_folders) + length(var.read_roles) > 0 ? 1 : 0
  bucket = aws_s3_bucket.default.id
  policy = module.bucket_policy.result_document
}

data "template_file" "public_folders_bucket_policy" {
  count    = length(var.public_folders)
  template = file("${path.module}/templates/bucket_policy_public_read.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.default.arn
    prefix     = var.public_folders[count.index]
  }
}

data "template_file" "read_access_role_bucket_policy" {
  count    = length(var.read_roles)
  template = file("${path.module}/templates/bucket_policy_role_read.json.tpl")
  vars = {
    bucket_arn       = aws_s3_bucket.default.arn
    aws_resource_arn = var.read_roles[count.index]
  }
}

# merge pipeline policies into one document
module "bucket_policy" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-policy-document-aggregator.git?ref=0.6.0"
  source_documents = concat(
    data.template_file.public_folders_bucket_policy[*].rendered,
  data.template_file.read_access_role_bucket_policy[*].rendered)
}

#################
# IAM policies
#################

data "template_file" "write_access" {
  count    = length(var.write_policy_prefix)
  template = file("${path.module}/templates/iam_policy_s3_write.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.default.arn
    prefix     = var.write_policy_prefix[count.index]
  }
}

resource "aws_iam_policy" "s3_write_pipelines" {
  count  = length(var.write_policy_prefix)
  name   = "${var.project}-s3_write_${var.bucket_name}_${count.index}"
  policy = data.template_file.write_access[count.index].rendered
}
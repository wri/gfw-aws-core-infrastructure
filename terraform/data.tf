data "template_file" "pipelines_bucket_policy" {
  template = file("policies/s3_public.json")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "tiles_bucket_policy_public" {
  template = file("policies/s3_public.json")
  vars = {
    bucket_arn = aws_s3_bucket.pipelines.arn
  }
}

data "template_file" "tiles_bucket_policy_cloudfront" {
  template = file("policies/s3_aws.json")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = aws_cloudfront_distribution.tiles.arn
  }
}

data "template_file" "tiles_bucket_policy_lambda" {
  template = file("policies/s3_aws.json")
  vars = {
    bucket_arn       = aws_s3_bucket.tiles.arn
    aws_resource_arn = aws_iam_role.lambda_edge_cloudfront.arn
  }
}
//data "template_file" "tiles_bucket_policy_lambda" {
//  template = file("policies/s3_aws.json")
//  vars = {
//    bucket_arn = aws_s3_bucket.tiles.arn
//    aws_resource_arn = ""
//  }
//}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_edge_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_caller_identity" "current" {}

locals {
  module_name = "tile_cache"
}

data "archive_file" "redirect_latest_tile_cache" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/redirect_latest_tile_cache/src"
  output_path = "${path.module}/lambda_functions/redirect_latest_tile_cache.zip"
}

data "archive_file" "reset_response_header_caching" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/reset_response_header_caching/src"
  output_path = "${path.module}/lambda_functions/reset_response_header_caching.zip"
}

resource "aws_lambda_function" "redirect_latest_tile_cache" {
  function_name    = "${var.project}-${local.module_name}-redirect_latest_tile_cache"
//  function_name    = "redirect_latest_tile_cache"
  filename         = data.archive_file.redirect_latest_tile_cache.output_path
  source_code_hash = data.archive_file.redirect_latest_tile_cache.output_base64sha256
  role             = aws_iam_role.lambda_edge_cloudfront.arn
  runtime          = "nodejs8.10"
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 3
  publish          = true
  tags             = var.tags
}

resource "aws_lambda_function" "reset_response_header_caching" {
  function_name    = "${var.project}-${local.module_name}-reset_response_header_caching"
//  function_name    = "reset_response_header_caching"
  filename         = data.archive_file.reset_response_header_caching.output_path
  source_code_hash = data.archive_file.reset_response_header_caching.output_base64sha256
  role             = aws_iam_role.lambda_edge_cloudfront.arn
  runtime          = "nodejs8.10"
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 1
  publish          = true
  tags             = var.tags
}

#
# Lambda@Edge IAM resources
#

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


resource "aws_iam_role" "lambda_edge_cloudfront" {
  name               = "${var.project}-${local.module_name}-lambda_edge_cloudfront"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_edge_basic_exec" {
  role       = aws_iam_role.lambda_edge_cloudfront.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.lambda_edge_cloudfront.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

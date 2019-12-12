resource "aws_lambda_function" "redirect_latest_tile_cache" {
//  function_name    = "${local.project}-redirect_latest_tile_cache"
  function_name    = "redirect_latest_tile_cache"
  filename         = data.archive_file.redirect_latest_tile_cache.output_path
  source_code_hash = data.archive_file.redirect_latest_tile_cache.output_base64sha256
  role             = aws_iam_role.lambda_edge_cloudfront.arn
  runtime          = "nodejs8.10"
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 3
  publish          = true
  tags             = local.tags
}

resource "aws_lambda_function" "reset_response_header_caching" {
//  function_name    = "${local.project}-reset_response_header_caching"
  function_name    = "reset_response_header_caching"
  filename         = data.archive_file.reset_response_header_caching.output_path
  source_code_hash = data.archive_file.reset_response_header_caching.output_base64sha256
  role             = aws_iam_role.lambda_edge_cloudfront.arn
  runtime          = "nodejs8.10"
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 1
  publish          = true
  tags             = local.tags
}
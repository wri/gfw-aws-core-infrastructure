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


data "aws_caller_identity" "current" {}

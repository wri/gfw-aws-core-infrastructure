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
  name               = "${local.project}-lambda_edge_cloudfront"
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

//resource "aws_iam_role_policy_attachment" "lambda_edge_logging" {
//  role       = aws_iam_role.lambda_edge_cloudfront.name
//  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSCloudFrontLogger"
//}


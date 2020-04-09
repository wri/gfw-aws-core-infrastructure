resource "aws_iam_policy" "s3_write_pipelines" {
  name   = "${local.project}-s3_write_pipelines"
  policy = data.template_file.s3_write_pipelines.rendered
}

resource "aws_iam_policy" "s3_write_data-lake" {
  name   = "${local.project}-s3_write_data-lake"
  policy = data.template_file.s3_write_data-lake.rendered

}

resource "aws_iam_policy" "s3_write_tiles" {
  name   = "${local.project}-s3_write_tiles"
  policy = data.template_file.s3_write_tiles.rendered

}

resource "aws_iam_policy" "secrets_read_gfw-api-token" {
  name   = "${local.project}-secrets_read_gfw-api-token"
  policy = data.template_file.secrets_read_gfw-api-token.rendered
}

resource "aws_iam_policy" "secrets_read_slack-gfw-sync" {
  name   = "${local.project}-secrets_read_slack-gfw-sync"
  policy = data.template_file.secrets_read_slack-gfw-sync.rendered
}


resource "aws_iam_role" "iam_emr_service_role" {
  name               = "${local.project}-iam_emr_service_role"
  assume_role_policy = data.template_file.trust_emr.rendered
}

resource "aws_iam_role_policy" "iam_emr_service_policy" {
  name = "${local.project}-iam_emr_service_policy"
  role = aws_iam_role.iam_emr_service_role.id

  policy = data.local_file.emr_default_policy.content
}

resource "aws_iam_role" "iam_emr_profile_role" {
  name = "${local.project}-emr_profile"

  assume_role_policy = data.template_file.trust_ec2.rendered
}

resource "aws_iam_instance_profile" "emr_profile" {
  name = "${local.project}-emr_profile"
  role = aws_iam_role.iam_emr_profile_role.name
}

resource "aws_iam_role_policy" "iam_emr_profile_policy" {
  name = "${local.project}-iam_emr_profile_policy"
  role = aws_iam_role.iam_emr_profile_role.id

  policy = data.local_file.emr_ec2_default_policy.content
}

resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
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
  name               = "${local.project}-tile_cache-lambda_edge_cloudfront"
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
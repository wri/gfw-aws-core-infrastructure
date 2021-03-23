resource "aws_sns_topic" "data_discovery_topic" {
  name = "dataset-discovery${var.bucket_suffix}"
  tags = var.tags
}

resource "aws_iam_group" "sns_publishers" {
  name = "data_discovery_publishers"
}

data "aws_iam_policy_document" "partner_sns_publish_policy_doc" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.data_discovery_topic.arn]
    effect = "Allow"
  }
  statement {
    actions   = ["arn:aws:sns:::*"]
    resources = [aws_sns_topic.data_discovery_topic.arn]
    effect = "Deny"
  }
}

 resource "aws_iam_policy" "policy" {
   name        = "partner_sns_publish_policy"
   description = "Policy for partners/services to publish data update availability to"
   policy = data.aws_iam_policy_document.partner_sns_publish_policy_doc.json
}

resource "aws_iam_group_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.policy.arn
  group = aws_iam_group.sns_publishers.name
}
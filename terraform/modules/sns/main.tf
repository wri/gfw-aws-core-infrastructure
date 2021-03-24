resource "aws_sns_topic" "data_discovery_topic" {
  name = "dataset-discovery"
  tags = var.tags
}

resource "aws_iam_group" "sns_discovery_publishers_group" {
  name = "data_discovery_publishers"
}

data "aws_iam_policy_document" "partner_sns_publish_policy_doc" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.data_discovery_topic.arn]
    effect = "Allow"
  }
}

 resource "aws_iam_policy" "policy" {
   name        = "partner_sns_publish_policy"
   description = "Policy for partners/services to publish data update availability to"
   policy = data.aws_iam_policy_document.partner_sns_publish_policy_doc.json
}

resource "aws_iam_group_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.policy.arn
  group = aws_iam_group.sns_discovery_publishers_group.name
}
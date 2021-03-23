output "data_discovery_topic_arn" {
  value = aws_sns_topic.data_discovery_topic.arn
}

output "rendered_policy" {
  value = data.aws_iam_policy_document.partner_sns_publish_policy_doc.json
}

output "sns_publishers_group" {
  value = aws_iam_group.sns_publishers.arn
}
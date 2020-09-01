

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

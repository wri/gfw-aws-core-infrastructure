data "local_file" "ec2_assume" {
  filename = "${path.root}/policies/ec2_assume.json"
}

data "local_file" "spotfleet_assume" {
  filename = "${path.root}/policies/spotfleet_assume.json"
}

resource "aws_iam_role" "ec2_spot_fleet_role" {
  name               = "${var.project}-ec2_spot_fleet_role"
  assume_role_policy = data.local_file.spotfleet_assume.content
}

resource "aws_iam_role_policy_attachment" "ec2_spotfleet_tagging" {
  role       = aws_iam_role.ec2_spot_fleet_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

//resource "aws_iam_instance_profile" "ec2_spot_fleet_profile" {
//  name = "${var.project}-ec2_spot_fleet_profile"
//  role = aws_iam_role.ec2_spot_fleet_role.name
//}


resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.project}-ecs_instance_role"
  assume_role_policy = data.local_file.ec2_assume.content
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.project}-ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}


resource "aws_iam_role_policy_attachment" "ecs_instance_role_ec2_contantainer_service" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy_attachment" "ecs_instance_role_s3_read_access" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


resource "aws_iam_role_policy_attachment" "ecs_instance_role_s3_data-lake_write" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = var.s3_data-lake_write
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_s3_tiles_write" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = var.s3_tiles_write
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_s3_pipelines_write" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = var.s3_pipelines_write
}


resource "aws_security_group" "batch" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = "${var.project}-sgBatch"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "default_http_egress" {
  type             = "egress"
  from_port        = "80"
  to_port          = "80"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.batch.id
}

resource "aws_security_group_rule" "default_https_egress" {
  type             = "egress"
  from_port        = "443"
  to_port          = "443"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.batch.id
}

resource "aws_security_group_rule" "default_ssh_egress" {
  type        = "egress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.vpc_cidr_blocks

  security_group_id = aws_security_group.batch.id
}

data "local_file" "batch_assume" {
  filename = "${path.root}/policies/batch_assume.json"
}

resource "aws_iam_role" "aws_batch_service_role" {
  name               = "${var.project}-aws_batch_service_role"
  assume_role_policy = data.local_file.batch_assume.content
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_batch_compute_environment" "ephemeral-storage" {
  compute_environment_name = "${var.project}-ephemeral-storage"

  compute_resources {

    bid_percentage = 100
    ec2_key_pair   = var.key_pair

    instance_role       = aws_iam_instance_profile.ecs_instance_profile.arn
    spot_iam_fleet_role = aws_iam_role.ec2_spot_fleet_role.arn

    instance_type = [
      "r5d", "c5d"
    ]

    max_vcpus = 256
    min_vcpus = 0

    security_group_ids = [aws_security_group.batch.id]

    subnets = var.subnets
    launch_template {
      launch_template_id = var.launch_template_id
      version            = var.launch_template_latest_version
    }

    type = "SPOT"
    tags = var.tags
  }

  lifecycle {
    ignore_changes = [
      compute_resources.0.desired_vcpus,
    ]
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  state        = "ENABLED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]


}
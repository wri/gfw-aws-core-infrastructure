resource "aws_launch_template" "ecs-optimized-ephemeral-storage-mounted" {

  name = "${local.project}-ECS-optimized-ephemeral-storage-mounted"

  disable_api_termination = false
  image_id                = data.aws_ami.latest-amazon-ecs-optimized.image_id
  security_group_names    = []
  tags                    = local.tags
  //       vpc_security_group_ids               = []

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = "true"
      encrypted             = "false"
      snapshot_id           = data.aws_ami.latest-amazon-ecs-optimized.root_snapshot_id
      volume_size           = 256
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }
  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  user_data = data.local_file.mount_nvme1n1_mime.content_base64
}

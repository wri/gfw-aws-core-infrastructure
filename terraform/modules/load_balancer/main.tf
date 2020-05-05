#
# NLB Resources
# This LB is shared across multiple resources and hence defined in the core repo
# To be consistent, me must define security groups and listener ports for these resources here
#
resource "aws_lb" "default" {
  name                             = substr("${var.project}-loadbalancer${var.name_suffix}", 0, 32)
  enable_cross_zone_load_balancing = true

  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb.id]

  tags = merge(
    {
      Job = var.project,
    },
    var.tags
  )
}

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "${var.project}-ecs-alb${var.name_suffix}"
  description = "Controls access to the ALB"
  vpc_id      = var.vpc_id

  # Data API rules
  ingress {
    from_port   = var.data_api_listener_port
    to_port     = var.data_api_listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  egress {
  //    from_port   = var.data_api_listener_port
  //    to_port     = var.data_api_listener_port
  //    protocol    = "tcp"
  //    security_groups = [aws_security_group.data_api_tasks.arn]
  //  }

  # Tile cache rules
  ingress {
    from_port   = var.tile_cache_listener_port
    to_port     = var.tile_cache_listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  egress {
  //    from_port   = var.tile_cache_listener_port
  //    to_port     = var.tile_cache_listener_port
  //    protocol    = "tcp"
  //    security_groups = [aws_security_group.tile_cache_tasks.id]
  //  }

  tags = merge(
    {
      Name = "${var.project}-ecs-alb${var.name_suffix}"
    },
    var.tags
  )
}

# these rules depends on other security groups so separating them allows them
# to be created after both
resource "aws_security_group_rule" "lb_data_api_egress" {
  security_group_id        = aws_security_group.lb.id
  from_port                = var.data_api_listener_port
  to_port                  = var.data_api_listener_port
  protocol                 = "tcp"
  type                     = "egress"
  source_security_group_id = aws_security_group.data_api_tasks.id
}

resource "aws_security_group_rule" "lb_tile_cache_egress" {
  security_group_id        = aws_security_group.lb.id
  from_port                = var.tile_cache_listener_port
  to_port                  = var.tile_cache_listener_port
  protocol                 = "tcp"
  type                     = "egress"
  source_security_group_id = aws_security_group.tile_cache_tasks.id
}

# Traffic to the ECS Cluster should only come from the ALB
# Task should only communicate with the ALB
# Additional ports to databases and alike can be opened in additional SG
resource "aws_security_group" "data_api_tasks" {
  name        = "${var.project}-data_api_tasks${var.name_suffix}"
  description = "Allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.data_api_container_port
    to_port         = var.data_api_container_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol        = "tcp"
    from_port       = var.data_api_container_port
    to_port         = var.data_api_container_port
    security_groups = [aws_security_group.lb.id]
  }

  tags = merge(
    {
      Name = "${var.project}-data_api_tasks${var.name_suffix}"
    },
    var.tags
  )
}


# Traffic to the ECS Cluster should only come from the ALB
# Task should only communicate with the ALB
# Additional ports to databases and alike can be opened in additional SG
resource "aws_security_group" "tile_cache_tasks" {
  name        = "${var.project}-tile_cache_tasks${var.name_suffix}"
  description = "Allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.tile_cache_container_port
    to_port         = var.tile_cache_container_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol        = "tcp"
    from_port       = var.tile_cache_container_port
    to_port         = var.tile_cache_container_port
    security_groups = [aws_security_group.lb.id]
  }

  tags = merge(
    {
      Name = "${var.project}-tile_cache_tasks${var.name_suffix}"
    },
    var.tags
  )
}
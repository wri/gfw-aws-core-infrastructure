resource "aws_security_group" "default" {
  vpc_id = module.vpc.id

  tags = merge(
    {
      Name = "${var.project}-sgDefault"
    },
    local.tags
  )
}




resource "aws_security_group_rule" "default_ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["216.70.220.184/32"]
  //  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_ssh_egress" {
  type      = "egress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
  module.vpc.cidr_block]

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_http_egress" {
  type             = "egress"
  from_port        = "80"
  to_port          = "80"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "default_https_egress" {
  type             = "egress"
  from_port        = "443"
  to_port          = "443"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}

//resource "aws_security_group" "default" {
//  name = "${local.project}-security_group"
//
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}
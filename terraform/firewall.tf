// DEFAUlT Security Group
// SSH in From WRI office, 80 and 443 out

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
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["216.70.220.184/32"]
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

// EMR Master

resource "aws_security_group" "emr-master" {
  vpc_id = module.vpc.id

  tags = merge(
    {
      Name = "${local.project}-emr-master"
    },
    local.tags
  )
}

resource "aws_security_group_rule" "emr-master_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["216.70.220.184/32"]
  security_group_id = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_all_tcp_ingress-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_all_tcp_ingress-worker" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr-worker.id
  security_group_id        = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_all_udp_ingress-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_all_udp_ingress-workerr" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr-worker.id
  security_group_id        = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_all_icmp_ingress-self" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  self              = true
  security_group_id = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_all_icmp_ingress-worker" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr-worker.id
  security_group_id        = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_8443_ingress" {
  type      = "ingress"
  from_port = 8443
  to_port   = 8443
  protocol  = "tcp"
  cidr_blocks = ["207.171.167.25/32",
    "54.240.217.8/29",
    "72.21.196.64/29",
    "72.21.198.64/29",
    "54.240.217.16/29",
    "54.239.98.0/24",
    "207.171.167.101/32",
    "207.171.167.26/32",
    "72.21.217.0/24",
    "54.240.217.80/29",
    "54.240.217.64/28",
  "207.171.172.6/32"]
  security_group_id = aws_security_group.emr-master.id
}

resource "aws_security_group_rule" "emr-master_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.emr-master.id
}

// EMR Worker

resource "aws_security_group" "emr-worker" {
  vpc_id = module.vpc.id

  tags = merge(
    {
      Name = "${local.project}-emr-worker"
    },
    local.tags
  )
}

resource "aws_security_group_rule" "emr-worker_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["216.70.220.184/32"]
  security_group_id = aws_security_group.emr-worker.id
}

resource "aws_security_group_rule" "emr-worker_all_tcp_ingress-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.emr-worker.id
}

resource "aws_security_group_rule" "emr-worker_all_tcp_ingress-master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr-master.id
  security_group_id        = aws_security_group.emr-worker.id
}

resource "aws_security_group_rule" "emr-worker_all_udp_ingress-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.emr-worker.id
}

resource "aws_security_group_rule" "emr-worker_all_udp_ingress-master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.emr-master.id
  security_group_id        = aws_security_group.emr-worker.id
}

resource "aws_security_group_rule" "emr-worker_all_icmp_ingress-self" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  self              = true
  security_group_id = aws_security_group.emr-worker.id
}

resource "aws_security_group_rule" "emr-worker_all_icmp_ingress-master" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.emr-master.id
  security_group_id        = aws_security_group.emr-worker.id
}

resource "aws_security_group_rule" "emr-worker_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.emr-worker.id
}

# We don't need redundancies the same level of redundancies in staging and dev as in production.


locals {
  # saving costs for now, might want to scale nb of NAT gateways up at in production at a later point
  nb_nat = 1 # var.environment == "production" ? length(var.private_subnet_cidr_blocks) : 1
}

#
# VPC resources
#
resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.project}-vpc"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name = "${var.project}-PrivateRouteTable"
    },
    var.tags
  )
}

resource "aws_route" "private" {
  count = length(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[0].id # aws_nat_gateway.default[var.environment == "production" ? count.index : 0].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name = "${var.project}-PublicRouteTable"
    },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "private" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.project}-PrivateSubnet-${var.availability_zones[count.index]}"
    },
    var.tags,
    //    var.private_subnet_tags
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.project}-PublicSubnet-${var.availability_zones[count.index]}"
    },
    var.tags,
    //    var.public_subnet_tags
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.default.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = flatten([
    aws_route_table.public.id,
    aws_route_table.private.*.id
  ])

  tags = merge(
    {
      Name = "${var.project}-endpointS3"
    },
    var.tags
  )
}


#
# NAT resources
#
resource "aws_eip" "nat" {
  count = local.nb_nat

  vpc = true

  tags = merge(
    {
      Name = "${var.project}-NAT_gateway-${count.index}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "default" {
  depends_on = [aws_internet_gateway.default]

  count = local.nb_nat

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.project}-gwNAT"
    },
    var.tags
  )
}

#
# Bastion resources
#
data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_ami.id
  availability_zone           = var.availability_zones[0]
  ebs_optimized               = true
  instance_type               = var.bastion_instance_type
  monitoring                  = true
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  user_data                   = data.template_file.bastion_setup.rendered

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    {
      Name = "${var.project}-Bastion"
    },
    var.tags
  )
}


# User data script to bootstrap authorized ssh keys
data "template_file" "bastion_setup" {
  template = file("${path.module}/user_data/bastion_setup.sh.tpl")
  vars = {
    user                = "ec2-user"
    authorized_ssh_keys = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ec2-user/.ssh/authorized_keys", var.keys)~}
${row}
%{endfor~}
EOT
  }
}

resource "aws_eip" "bastion" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}
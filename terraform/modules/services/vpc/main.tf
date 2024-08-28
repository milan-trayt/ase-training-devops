data "aws_availability_zones" "azs" {}
data "aws_region" "current" {}

locals {
  name = join("-", [var.stage, var.project, var.module, "vpc"])

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "vpc"])
    Exposure    = "public/private"
    Description = "vpc for ${var.stage} environment"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-igw"
      Description = "Internet Gateway for public subnets"
      Exposure    = "public"
    }
  )
}

resource "aws_subnet" "private_subnet" {
  count = var.az_count

  cidr_block        = cidrsubnet(var.cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-private-subnet-${count.index}"
      Description = "Private subnet for vpc"
      Exposure    = "private"
    }
  )
}

resource "aws_subnet" "private_database_subnet" {
  count = var.az_count

  cidr_block        = cidrsubnet(var.cidr, 8, 18 + var.az_count + count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-private-database-subnet-${count.index}"
      Description = "Private database subnet to isolate the database"
      Exposure    = "private"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  count = var.az_count

  cidr_block              = cidrsubnet(var.cidr, 8, 8 + var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-public-subnet-${count.index}"
      Description = "Public subnet for vpc"
      Exposure    = "public"
    }
  )
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "all"
    rule_no         = 101
    action          = "deny"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol        = "all"
    rule_no         = 101
    action          = "deny"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  dynamic "egress" {
    for_each = var.nacl_egress_rule
    content {
      from_port       = lookup(egress.value, "port", 0)
      to_port         = lookup(egress.value, "to_port", egress.value.port)
      protocol        = egress.value.protocol
      cidr_block      = lookup(egress.value, "ipv4_cidr", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr", null)
      rule_no         = egress.value.rule_no
      action          = egress.value.action
    }
  }

  dynamic "ingress" {
    for_each = var.nacl_ingress_rule
    content {
      from_port       = lookup(ingress.value, "port", 0)
      to_port         = lookup(ingress.value, "to_port", ingress.value.port)
      protocol        = ingress.value.protocol
      cidr_block      = lookup(ingress.value, "ipv4_cidr", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr", null)
      rule_no         = ingress.value.rule_no
      action          = ingress.value.action
    }
  }

  tags = {
    Name = "${local.name}-nacl"
  }
}

resource "aws_network_acl" "private_database" {
  vpc_id = aws_vpc.main.id

  dynamic "egress" {
    for_each = var.nacl_egress_rule
    content {
      from_port       = lookup(egress.value, "port", 0)
      to_port         = lookup(egress.value, "to_port", egress.value.port)
      protocol        = egress.value.protocol
      cidr_block      = lookup(egress.value, "ipv4_cidr", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr", null)
      rule_no         = egress.value.rule_no
      action          = egress.value.action
    }
  }

  dynamic "ingress" {
    for_each = var.nacl_ingress_rule
    content {
      from_port       = lookup(ingress.value, "port", 0)
      to_port         = lookup(ingress.value, "to_port", ingress.value.port)
      protocol        = ingress.value.protocol
      cidr_block      = lookup(ingress.value, "ipv4_cidr", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr", null)
      rule_no         = ingress.value.rule_no
      action          = ingress.value.action
    }
  }
}

resource "aws_network_acl_association" "private_database" {
  count          = var.az_count
  network_acl_id = aws_network_acl.private_database.id

  subnet_id = aws_subnet.private_database_subnet[count.index].id
}

resource "aws_network_acl_association" "private" {
  count          = var.az_count
  network_acl_id = aws_network_acl.main.id

  subnet_id = aws_subnet.private_subnet[count.index].id
}

resource "aws_network_acl_association" "public" {
  count          = var.az_count
  network_acl_id = aws_network_acl.main.id

  subnet_id = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-private-route"
      Exposure    = "private"
      Description = "private route table for vpc"
    }
  )

  depends_on = [aws_subnet.private_subnet]
}

resource "aws_route_table" "private_database_route" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-private-database-route"
      Exposure    = "private"
      Description = "private route table for database subnet"
    }
  )

  depends_on = [aws_subnet.private_subnet]
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-public-route"
      Exposure    = "public"
      Description = "public route table for vpc"
    }
  )

  depends_on = [aws_subnet.public_subnet]
}

resource "aws_route_table_association" "private_route_ass" {
  count = var.az_count

  route_table_id = aws_route_table.private_route.id
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
}

resource "aws_route_table_association" "private_database_route_ass" {
  count = var.az_count

  route_table_id = aws_route_table.private_database_route.id
  subnet_id      = element(aws_subnet.private_database_subnet.*.id, count.index)
}

resource "aws_route_table_association" "public_route_ass" {
  count = var.az_count

  route_table_id = aws_route_table.public_route.id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}

resource "aws_eip" "nat_eip" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"
  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-nat-gateway-eip"
      Description = "elastic ip for nat gateway"
      Exposure    = "public"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_gw" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    local.tags,
    {
      Name        = "${local.name}-nat-gateway"
      Description = "nat gateway for private subnets"
      Exposure    = "private"
    }
  )
}

resource "aws_route" "nat_route" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}


# Route the Public Subnet through IGW
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


resource "aws_flow_log" "this" {
  count = var.enable_flow_log ? 1 : 0

  iam_role_arn    = aws_iam_role.this[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = local.tags
}
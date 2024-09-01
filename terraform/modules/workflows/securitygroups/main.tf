resource "aws_security_group" "sg_alb" {
  name        = join("-", [var.stage, var.project, var.module, "SECGROUP-ALB"])
  description = "access to alb"
  vpc_id      = var.vpc_id

  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "SECGROUP-ALB"])
    Exposure    = "private"
    Description = "alb security group for ${var.stage} environment"
  }
}

resource "aws_security_group" "sg_api" {
  name        = join("-", [var.stage, var.project, var.module, "SECGROUP-API"])
  description = "access to api"
  vpc_id      = var.vpc_id

  ingress {
    description     = "port access"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    description     = "https access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    description = "ssh access from vpn server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.lf_public_ips
  }

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "SECGROUP-API"])
    Exposure    = "private"
    Description = "api instance security group for ${var.stage} environment"
  }
}


resource "aws_security_group_rule" "api_postgres_egress" {
  security_group_id        = aws_security_group.sg_api.id
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  type                     = "egress"
  source_security_group_id = aws_security_group.sg_postgres.id
}

resource "aws_security_group_rule" "api_https_egress" {
  security_group_id = aws_security_group.sg_api.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "api_http_egress" {
  security_group_id = aws_security_group.sg_api.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group" "sg_postgres" {
  name        = join("-", [var.stage, var.project, var.module, "SECGROUP-POSTGRES"])
  description = "access to postgres"
  vpc_id      = var.vpc_id

  ingress {
    description = "Self Cluster Access"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    self        = true
  }

  ingress {
    description     = "API Access"
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_api.id]
  }

  ingress {
    description = "access from vpn server"
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = local.lf_public_ips
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Self Cluster Access"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    self        = true
  }

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "SECGROUP-POSTGRES"])
    Exposure    = "private"
    Description = "postgres instance security group for ${var.stage} environment"
  }
}
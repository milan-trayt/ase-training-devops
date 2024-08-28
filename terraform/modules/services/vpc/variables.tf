variable "stage" {
  type = string
}

variable "project" {
  type = string
}

variable "module" {
  type = string
}

variable "cidr" {
  type = string
}

variable "az_count" {
  type    = number
  default = 3
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_flow_log" {
  type        = bool
  default     = true
  description = "enable or disable flow logs for vpc"
}

variable "flow_log_retention" {
  type        = number
  default     = 14
  description = "number of days to retain the flow log in cloudwatch log group"
}

variable "nacl_egress_rule" {
  type = list(any)
  default = [
    {
      rule_no   = "100"
      port      = 0
      protocol  = "all"
      ipv4_cidr = "0.0.0.0/0"
      action    = "allow"
    },
    {
      rule_no   = "101"
      port      = 0
      protocol  = "all"
      ipv6_cidr = "::/0"
      action    = "allow"
    }
  ]

  description = "A list of egress rule for NACL"
}

variable "nacl_ingress_rule" {
  type = list(any)
  default = [
    {
      rule_no   = "100"
      port      = 443
      protocol  = "tcp"
      ipv4_cidr = "0.0.0.0/0"
      action    = "allow"
    },
    {
      rule_no   = "101"
      port      = 80
      protocol  = "tcp"
      ipv4_cidr = "0.0.0.0/0"
      action    = "allow"
    },
    {
      rule_no   = "102"
      port      = 443
      protocol  = "tcp"
      ipv6_cidr = "::/0"
      action    = "allow"
    },
    {
      rule_no   = "103"
      port      = 80
      protocol  = "tcp"
      ipv6_cidr = "::/0"
      action    = "allow"
    },
    {
      rule_no   = "200"
      port      = 22
      protocol  = "tcp"
      ipv4_cidr = "10.0.0.0/8"
      action    = "allow"
    },
    {
      rule_no   = "201"
      port      = 3389
      protocol  = "tcp"
      ipv4_cidr = "10.0.0.0/8"
      action    = "allow"
    },
    {
      rule_no   = "300"
      port      = 1024
      to_port   = 3388
      protocol  = "tcp"
      ipv4_cidr = "0.0.0.0/0"
      action    = "allow"
    },
    {
      rule_no   = "301"
      port      = 1024
      to_port   = 3388
      protocol  = "tcp"
      ipv6_cidr = "::/0"
      action    = "allow"
    },
    {
      rule_no   = "302"
      port      = 1024
      to_port   = 3388
      protocol  = "udp"
      ipv4_cidr = "0.0.0.0/0"
      action    = "allow"
    },
    {
      rule_no   = "303"
      port      = 1024
      to_port   = 3388
      protocol  = "udp"
      ipv6_cidr = "::/0"
      action    = "allow"
    },
    {
      rule_no   = "304"
      port      = 3390
      to_port   = 65535
      protocol  = "tcp"
      ipv4_cidr = "0.0.0.0/0"
      action    = "allow"
    },
    {
      rule_no   = "305"
      port      = 3390
      to_port   = 65535
      protocol  = "tcp"
      ipv6_cidr = "::/0"
      action    = "allow"
    },
    {
      rule_no   = "306"
      port      = 3390
      to_port   = 65535
      protocol  = "udp"
      ipv4_cidr = "0.0.0.0/0"
      action    = "allow"
    },
    {
      rule_no   = "307"
      port      = 3390
      to_port   = 65535
      protocol  = "udp"
      ipv6_cidr = "::/0"
      action    = "allow"
    }
  ]

  description = "A list of ingress rule for NACL"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "database_port" {
  type    = number
  default = 5432
}

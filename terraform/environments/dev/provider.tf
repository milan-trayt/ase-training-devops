terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Name      = "milan-splittr",
      Project   = "milan-splittr"
      Creator   = "milanpokhrel@lftechnology.com"
      Deletable = "Yes"
    }
  }
}

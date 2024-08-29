terraform {
  backend "s3" {
    bucket         = "milan-splittr-tfstate-dev"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "milan-splittr-tflock-dev"
  }
}
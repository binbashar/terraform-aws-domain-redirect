terraform {
  required_version = ">=0.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

module "domain-redirect" {
  source = "github.com/byu-oit/terraform-aws-domain-redirect?ref=v1.0.0"
  #source = "../" # for local testing during module development
  source_domain = "redirect-test.byu-oit-terraform-dev.amazon.byu.edu"
  target_url    = "byu.edu"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

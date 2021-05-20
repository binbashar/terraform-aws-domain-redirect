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
  alias  = "us-east-1"
}

module "ci_test" {
  source        = "../../"
  source_domain = "redirect-test.byu-oit-terraform-dev.amazon.byu.edu"
  target_url    = "byu.edu"
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}

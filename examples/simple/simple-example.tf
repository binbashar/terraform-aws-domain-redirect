provider "aws" {
  version = "~> 2.42"
  region  = "us-west-2"
}

module "domain-redirect" {
  source = "github.com/byu-oit/terraform-aws-domain-redirect?ref=v1.0.0"
  #source = "../" # for local testing during module development
}

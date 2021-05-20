provider "aws" {
  region = "us-west-2"
}

locals {
  test_domain_name = "redirect-test.${data.aws_route53_zone.terraform_dev_zone.name}"
}

data "aws_route53_zone" "terraform_dev_zone" {
  name = "byu-oit-terraform-dev.amazon.byu.edu"
}

resource "aws_route53_zone" "test_zone" {
  name = local.test_domain_name
}

resource "aws_route53_record" "ns_to_test_zone" {
  name    = local.test_domain_name
  type    = "NS"
  ttl     = 172800
  zone_id = data.aws_route53_zone.terraform_dev_zone.zone_id
  records = [
    aws_route53_zone.test_zone.name_servers[0],
    aws_route53_zone.test_zone.name_servers[1],
    aws_route53_zone.test_zone.name_servers[2],
    aws_route53_zone.test_zone.name_servers[3]
  ]
}

output "zone" {
  value = aws_route53_zone.test_zone
}

terraform {
  required_version = ">=0.15.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 3.4.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}

locals {
  bucket_name = var.redirect_bucket_name != null ? var.redirect_bucket_name : "${var.source_hosted_zone_name}-redirect"
  domain_urls = setunion([var.source_hosted_zone_name], var.source_hosted_zone_sub_domains)
}

data "aws_route53_zone" "source_zone" {
  name = var.source_hosted_zone_name
}

// ***** START SSL certificate for the source zone *****
// SSL certificate for CloudFront distribution
resource "aws_acm_certificate" "cert_us_east_1" {
  provider          = aws.us-east-1
  domain_name       = data.aws_route53_zone.source_zone.name
  validation_method = "DNS"
  tags              = var.tags

  subject_alternative_names = var.source_hosted_zone_sub_domains

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation_record_us_east_1" {
  provider = aws.us-east-1
  for_each = {
    for dvo in aws_acm_certificate.cert_us_east_1.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.source_zone.zone_id
}

resource "aws_acm_certificate_validation" "validation_us_east_1" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert_us_east_1.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record_us_east_1 : record.fqdn]
}

// ***** END SSL certificate for the source zone


// ***** START CloudFront redirect *****

// A records sends traffic to CloudFront
resource "aws_route53_record" "redirect_records" {
  for_each = local.domain_urls
  name     = each.value
  type     = "A"
  zone_id  = data.aws_route53_zone.source_zone.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
  }
}

resource "aws_route53_record" "redirect_aaaa_records" {
  for_each = local.domain_urls
  name     = each.value
  type     = "AAAA"
  zone_id  = data.aws_route53_zone.source_zone.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
  }
}

// CloudFront sends traffic to redirect bucket
resource "aws_cloudfront_distribution" "redirect" {
  price_class = "PriceClass_100"
  origin {
    domain_name = aws_s3_bucket.redirect_bucket.website_endpoint
    origin_id   = aws_s3_bucket.redirect_bucket.bucket

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  comment         = "${var.source_hosted_zone_name} redirect to ${var.target_url}"
  enabled         = true
  is_ipv6_enabled = true
  aliases         = local.domain_urls
  tags            = var.tags

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.redirect_bucket.bucket
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.validation_us_east_1.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}

// ***** END cloudfront redirect *****

// ***** START Redirect bucket *****
// Redirects all traffic to the target_url
resource "aws_s3_bucket" "redirect_bucket" {
  bucket = local.bucket_name
  website {
    redirect_all_requests_to = var.target_url
  }
  tags = var.tags

  lifecycle_rule {
    enabled                                = true
    abort_incomplete_multipart_upload_days = 10
    id                                     = "AutoAbortFailedMultipartUpload"

    expiration {
      days                         = 0
      expired_object_delete_marker = false
    }
  }
}

// ***** END redirect bucket *****

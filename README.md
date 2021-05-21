![Latest GitHub Release](https://img.shields.io/github/v/release/byu-oit/terraform-aws-domain-redirect?sort=semver)

# Terraform AWS Domain Redirect
This module manages all the AWS resources needed to provide the ability to redirect traffic for a domain to a different URL.

Unfortunately redirecting to a completely different domain is more complex than one would think.
See [architecture](#architecture).

#### [New to Terraform Modules at BYU?](https://github.com/byu-oit/terraform-documentation)

## Usage
```hcl
module "domain_redirect" {
  source                  = "github.com/byu-oit/terraform-aws-domain-redirect?ref=v1.0.0"
  source_hosted_zone_name = "extradomain.byu.edu"
  target_url              = "newdomain.byu.edu"
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}
```

This module is especially useful if you want to keep an old domain but want traffic to literally redirect to a new URL instead of just serving the content to the old domain.

## Requirements
* Terraform version 0.15.0 or greater
* Route53 Hosted Zone (`source_hosted_zone_name`) already created and DNS traffic sent to it
* us-east-1 region AWS provider needs to be passed into the module

*Note*: Terraform 0.15 is required because the module needs the us-east-1 provider because CloudFront still needs to place its SSL certificate in us-east-1.

## Inputs
| Name | Type  | Description | Default |
| --- | --- | --- | --- |
| source_hosted_zone_name | string | The source domain (name of the Route53 Hosted Zone) that will be redirected to target_url | |
| source_hosted_zone_sub_domains | set(string) | A list of sub domains in the source_hosted_zone_name that you also want to redirect to the target_url (optional) | [] |
| target_url | string | Where you want traffic to be redirected to | |
| redirect_bucket_name | string | Name of the s3 redirect bucket (optional) | <source_hosted_zone_name>-redirect|
| tags | map(string) | A map of AWS Tags to attach to each resource created (optional) | {} |
| providers.aws.us-east-1 | terraform provider | The us-east-1 AWS provider | |

## Outputs
| Name | Type | Description |
| ---  | ---  | --- |
| redirect_bucket | [object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#attributes-reference) | The static s3 site that redirects traffic to the `target_url` |
| redirect_cloudfront_distribution | [object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#attributes-reference) | The CloudFront Distribution that handles SSL to the `redirect_bucket` |

## Architecture

This module creates/manages these resources:

* Route53 A Records (for `source_hosted_zone_name` and any provided `source_hosted_zone_sub_domains`)
* SSL Certificate (validated)
* CloudFront Distribution
* S3 Static Site (set to redirect all traffic to `target_url`)


How this works...

1. Client attempts to reach `source_hosted_zone_name` URL
2. Goes to Route53 Hosted Zone
3. A records send traffic to CloudFront Distribution
4. CloudfrontDistribution sends to S3 Static Site
5. S3 Static Site redirects client to `target_url`


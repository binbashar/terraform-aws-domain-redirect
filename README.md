![Latest GitHub Release](https://img.shields.io/github/v/release/byu-oit/terraform-aws-domain-redirect?sort=semver)

# Terraform AWS Domain Redirect
This module manages all the AWS resources needed to provide the ability to redirect traffic for a domain to a different URL.

Unfortunately redirecting to a completely different domain is more complex than one would think.

#### [New to Terraform Modules at BYU?](https://github.com/byu-oit/terraform-documentation)

## Usage
```hcl
module "domain_redirect" {
  source = "github.com/byu-oit/terraform-aws-domain-redirect?ref=v1.0.0"
}
```

## Requirements
* Terraform version 0.12.16 or greater

## Inputs
| Name | Type  | Description | Default |
| --- | --- | --- | --- |
| | | | |

## Outputs
| Name | Type | Description |
| ---  | ---  | --- |
| | | |

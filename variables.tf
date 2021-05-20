variable "source_domain" {
  type        = string
  description = "The source domain that will be redirected to target_url"
}

variable "sub_domains" {
  type        = set(string)
  description = "A list of sub domains in the source_domain that you also want to redirect to the target_url (optional)"
  default     = []
}

variable "target_url" {
  type        = string
  description = "Where you want traffic to be redirected to"
}

variable "redirect_bucket_name" {
  type        = string
  description = "Name of the s3 redirect bucket (optional)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to each of the resources"
  default     = {}
}

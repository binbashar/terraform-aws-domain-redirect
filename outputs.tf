output "redirect_bucket" {
  value = aws_s3_bucket.redirect_bucket
}

output "redirect_cloudfront_distribution" {
  value = aws_cloudfront_distribution.redirect
}

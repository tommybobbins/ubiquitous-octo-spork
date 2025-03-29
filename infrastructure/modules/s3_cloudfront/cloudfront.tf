locals {
  region      = var.aws_region
  domain_name = var.domain_name
  subdomain   = "www"
}



#############
# S3
#############
module "website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3"

  bucket_prefix = replace("www.${var.domain_name}","/\\W/","")
  attach_policy = true
  policy        = data.aws_iam_policy_document.ui_bucket_policy.json

  block_public_policy = false
  restrict_public_buckets = false

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }
}

#############
# Cloudfront
#############
module "cdn" {
  source  = "terraform-module/cloudfront/aws"
  version = "~> 1"

  comment             = format("CloudFront Distribution For %s", local.domain_name)
  aliases             = ["${local.subdomain}.${local.domain_name}","${local.domain_name}"]
  default_root_object = "index.html"
  
  s3_origin_config = [{
    # domain_name = local.s3_region_domain
    domain_name = module.website.s3_bucket_bucket_regional_domain_name
  }]


  viewer_certificate = {
    acm_certificate_arn = aws_acm_certificate.ssl_certificate.arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior = {
    min_ttl                    = 1000
    default_ttl                = 1000
    max_ttl                    = 1000
    cookies_forward            = "none"
    response_headers_policy_id = "Managed-SecurityHeadersPolicy"
    headers = [
      "Origin",
      "Access-Control-Request-Headers",
      "Access-Control-Request-Method"
    ]
  }
}
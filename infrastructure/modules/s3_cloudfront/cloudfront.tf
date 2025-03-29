# Cloudfront distribution for main s3 site.
# resource "aws_cloudfront_distribution" "www_s3_distribution" {

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"
#   price_class         = "PriceClass_100"
#   aliases = ["www.${var.domain_name}", "${var.domain_name}"]

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = aws_s3_bucket.www.bucket
#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 1800
#     default_ttl            = 3600
#     max_ttl                = 31536000
#     compress               = true

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }
#   }

#   origin {
#     # domain_name = aws_s3_bucket.www.bucket_regional_domain_name
#     domain_name = aws_s3_bucket.www.website_endpoint
#     origin_id   = aws_s3_bucket.www.bucket
#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

# }

# resource "aws_cloudfront_origin_access_identity" "oai" {
# }


# # resource "aws_cloudfront_origin_access_control" "oac" {
# #   name                              = "cloudfront-bucket-${aws_s3_bucket.www.id}"
# #   description                       = ""
# #   origin_access_control_origin_type = "s3"
# #   signing_behavior                  = "always"
# #   signing_protocol                  = "sigv4"
# # }


# data "aws_iam_policy_document" "default" {
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.www.arn}/*"]
#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#       values   = [aws_cloudfront_distribution.www_s3_distribution.arn]
#     }
#   }
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.www.arn}/*"]
#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
#     }
#   }
#   statement {
#     actions   = ["s3:ListBucket"]
#     resources = [aws_s3_bucket.www.arn]

#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
#     }
#   }
# }

locals {
  region      = var.aws_region
  domain_name = var.domain_name
  subdomain   = "www"
}

# provider "aws" {
#   region = local.region
# }

# provider "aws" {
#   region = "us-east-1"
#   alias  = "useast1"
# }

######
# ACM
######

# data "aws_route53_zone" "this" {
#   name = local.domain_name
# }

# # https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-invalid-viewer-certificate/
# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 4"

#   providers = {
#     aws = aws.useast1
#   }

#   domain_name               = local.domain_name
#   zone_id                   = data.aws_route53_zone.this.id
#   subject_alternative_names = ["${local.subdomain}.${local.domain_name}"]
# }

#############
# S3
#############
module "website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3"

  bucket_prefix = replace("www.${var.domain_name}","/\\W/","")
  attach_policy = true
  policy        = data.aws_iam_policy_document.ui_bucket_policy.json

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
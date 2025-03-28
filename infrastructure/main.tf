module "enjiia" {
  source = "./modules/s3_cloudfront"

  # Common parameters you might want to configure
  domain_name         = var.domain_name
  github_repository   = var.github_repository
  
  common_tags = {
    Environment = "production"
    Project     = "enjiia"
    Terraform   = "true"
  }
}

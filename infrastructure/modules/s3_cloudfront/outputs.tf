output "cf_hosted_zone_id" {
    value = module.cdn.cloudfront_distribution_hosted_zone_id
}

output "cf_distribution_id" {
    value = module.cdn.cloudfront_distribution_id
}

output "cf_distribution_arn" {
    value = module.cdn.cloudfront_distribution_arn
}

output "cf_domain_name" {
    value = module.cdn.cloudfront_distribution_domain_name
}
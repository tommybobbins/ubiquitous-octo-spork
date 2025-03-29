variable "domain_name" {
  type        = string
  description = "The domain name for the website without the www."
}

variable "common_tags" {
  description = "Common tags you want applied to all components."
}

variable "github_repository" {
  type        = string
  description = "The github repository that runs the actions."
}

variable "aws_region" {
  type = string
  description = "AWS Region to create assets in"
  default = "us-east-1"
}
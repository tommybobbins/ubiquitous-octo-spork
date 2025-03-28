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

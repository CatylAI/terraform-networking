variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region."
  type        = string
}

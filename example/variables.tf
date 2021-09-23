# Common
variable "region" {
  description = "Your AWS region"
  type        = string
}



variable "tags" {
  description = "Tags to set on the resources."
  type        = map(string)
  default     = {}
}

# S3

variable "s3_bucket_name" {
  description = "Domain name. Must be unique, and already registered."
  type        = string
}

variable "s3_enable_logging" {
  type        = bool
  default     = true
  description = "Use logging for resources. Will create an extra bucket."
}

variable "s3_use_bucket_encryption" {
  type        = bool
  default     = true
  description = "Set this to true to encrypt your buckets with a KMS key."
}

variable "s3_force_destroy" {
  type        = bool
  default     = false
  description = "This value will force-delete your buckets with files sill inside. You have been warned. Do not use in Prod."
}

# Cloudfront
variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100" // Only US,Canada,Europe
}

variable "use_cloudfront_domain" {
  description = "Use CloudFront website address without Route53 and ACM certificate"
  type        = string
  default     = true
}

variable "cloudfront_log_cookies" {
  type        = bool
  default     = false
  description = "Log cookies in cloudfront. Only works in logging is true."
}

variable "aws_certificate_arn" {
  type        = string
  default     = null
  description = "SSL Certificate used to link the Cloudfront resource to the dns record."
}
variable "kms_enable_key_rotation" {
  type        = bool
  default     = true
  description = "Set this to true in order to enable key rotation. Only works if use_bucket_encryption is true. Recommend setting to true so you don't get locked out of your buckets!"
}




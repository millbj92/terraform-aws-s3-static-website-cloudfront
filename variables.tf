# Common
variable "tags" {
  description = "Tags to set on the resources."
  type        = map(string)
  default     = {}
}


# S3
variable "s3_bucket_name" {
  description = "Name of the bucket to be deployed"
  type        = string
}

variable "s3_enable_logging" {
  type        = bool
  default     = true
  description = "Use logging for resources. Will create an extra bucket."
}

variable "s3_enable_log_lifecycle" {
  type        = bool
  default     = true
  description = "Enable lifecycle rules on log buckets for archiving data."
}
variable "s3_log_transitions" {
  description = "When log lifecycles are enabled, describe their transitions.  Use DEEP_ARCHIVE if you plan on keeping data for 7-10 years or more. Good for meeting compliance."
  type = set(object({
    days          = number,
    storage_class = string
  }))
  default = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 60
      storage_class = "GLACIER"
    },
    #{
    #  days = 90
    #  storage_class = "DEEP_ARCHIVE"
    #}
  ]
}

variable "s3_logs_expire" {
  type        = bool
  default     = true
  description = "Set to true if you want logs to eventually expire."
}

variable "s3_log_expiration_in_days" {
  type        = number
  default     = 90
  description = "The number of days a log file has to live before expiration and permanent deletion."
}

variable "s3_use_bucket_encryption" {
  type        = bool
  default     = true
  description = "Set this to true to encrypt your buckets with a KMS key."
}
variable "s3_cors_rules" {
  type = object({
    allowed_headers = list(string),
    allowed_methods = list(string),
    allowed_origins = list(string),
    expose_headers  = list(string),
    max_age_seconds = number
  })
  default = {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
variable "s3_force_destroy" {
  type        = bool
  default     = false
  description = "This value will force-delete your buckets with files sill inside. You have been warned. Do not use in Prod."
}
variable "kms_enable_key_rotation" {
  type        = bool
  default     = true
  description = "Set this to true in order to enable key rotation. Only works if use_bucket_encryption is true. Recommend setting to true so you don't get locked out of your buckets!"
}

# Cloudfront
variable "cloudfront_log_cookies" {
  type        = bool
  default     = false
  description = "Log cookies in cloudfront. Only works in logging is true."
}

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


variable "aws_certificate_arn" {
  type        = string
  default     = null
  description = "SSL Certificate used to link the Cloudfront resource to the dns record."
}
# Common
variable "tags" {
  description = "Tags to set on the resources."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}


# S3
variable "s3_primary_bucket_name" {
  description = "Name of the bucket to be deployed"
  type        = string
}

variable "s3_routing_policy" {
  description = "s3 bucket routing policy, defined in json, or EOF format. Used for setting fine-tuned redirects from one sub-directory to another, or to another host altogether."
  type        = string
  default     = null
}

variable "s3_enable_logging" {
  type        = bool
  default     = true
  description = "Use logging for resources. Will create an extra bucket."
}

variable "s3_enable_primary_bucket_lifecycle" {
  type        = bool
  default     = true
  description = "Enable lifecycle rules for primary buckets. This will only effect previous versions of the bucket, and not the live data."
}
variable "s3_enable_primary_bucket_replication" {
  type        = bool
  default     = true
  description = "Replicate your primary bucket to another region. Recommended setting to true, as this promotes redundancy and lowers the blast radius if your bucket gets deleted."
}

variable "s3_replication_region" {
  type        = string
  default     = "us-west-1"
  description = "The region your primary bucket will replicate to."
}

variable "s3_acl_grant_canonical_user" {
  type        = bool
  default     = false
  description = "Find the canonical user id of the current acount and add it to the ACL."
}

variable "s3_primary_bucket_acl" {
  type        = string
  default     = "private"
  description = "Access Control List of the primary bucket. Setting it to anything above private is not recommended."
  #private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control. Conflicts with grant.
}

variable "s3_primary_acl_grants" {
  description = "Custom Access Control List grants for primary and replication buckets. Conflicts with 's3_primary_bucket_acl'."
  type = set(object({
    id           = string
    type         = string
    permissions  = list(string)
    uri          = string
    emailAddress = string
  }))
  default = [
    # {
    #   # Grant the LogDelivery S3 Subgroup READ_ACP and Write permissions on the primary bucket.
    #   type = "Group"
    #   permissions = ["READ_ACP", "WRITE"]
    #   uri = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    # },
    # {
    #   type = "AmazonCustomerByEmail"
    #   permissions = ["READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]
    #   email = "example@exmple.com"
    # }
  ]
}

variable "iam_assume_role_policy" {
  type        = string
  default     = null
  description = "Role policy definition for assuming a role capable of enabling replication in another region."
}

variable "s3_enable_log_lifecycle" {
  type        = bool
  default     = true
  description = "Enable lifecycle rules on log buckets for archiving data."
}

variable "s3_bucket_redirect" {
  description = "Setting this string will make your s3 bucket redirect to the specified url. Used as a global redirect - this setting will redirect to another hostname no matter what. If you'd like more control, use the s3_routing_policy variable."
  type        = string
  default     = null
}

variable "s3_primary_version_transitions" {
  description = "Back up previous versions of all files into a glacier account after a specified amount of time."
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
      days          = 100
      storage_class = "GLACIER"
    }
  ]
}

variable "s3_primary_version_expiration" {
  description = "The time it takes, in days, for non-current versioned files to expire."
  type        = number
  default     = 120
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
  description = "Cross Origin Resource Sharing configurations for the primary and replication buckets."
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
    allowed_origins = ["*"]
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

variable "cloudfront_enable_failover" {
  description = "Enable failover functionality with cloudfront"
  type        = bool
  default     = true
}

variable "use_cloudfront_domain" {
  description = "Use CloudFront primary address without Route53 and ACM certificate"
  type        = bool
  default     = true
}


variable "aws_certificate_arn" {
  type        = string
  default     = null
  description = "SSL Certificate used to link the Cloudfront resource to the dns record."
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.59.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "local_file" "routing_rules_input" {
  filename = var.s3_routing_rules_input
}

data "local_file" "iam_assume_role_policy" {
  filename = var.iam_assume_role_policy_input
}

module "aws_s3_bucket_cloudfront" {
  source                               = "../"
  s3_primary_bucket_name               = var.s3_primary_bucket_name
  s3_enable_logging                    = var.s3_enable_logging
  s3_enable_primary_bucket_lifecycle   = var.s3_enable_primary_bucket_lifecycle
  s3_enable_primary_bucket_replication = var.s3_enable_primary_bucket_replication
  s3_replication_region                = var.s3_replication_region
  s3_acl_grant_canonical_user          = var.s3_acl_grant_canonical_user
  s3_primary_bucket_acl                = var.s3_primary_bucket_acl
  s3_primary_acl_grants                = var.s3_primary_acl_grants
  s3_routing_policy                    = data.local_file.routing_rules_input.content
  s3_enable_log_lifecycle              = var.s3_enable_log_lifecycle
  s3_bucket_redirect                   = var.s3_bucket_redirect
  s3_primary_version_transitions       = var.s3_primary_version_transitions
  s3_primary_version_expiration        = var.s3_primary_version_expiration
  s3_log_transitions                   = var.s3_log_transitions
  s3_logs_expire                       = var.s3_logs_expire
  s3_use_bucket_encryption             = var.s3_use_bucket_encryption
  s3_cors_rules                        = var.s3_cors_rules
  s3_force_destroy                     = var.s3_force_destroy
  s3_log_expiration_in_days            = var.s3_log_expiration_in_days
  iam_assume_role_policy               = data.local_file.iam_assume_role_policy.content
  kms_enable_key_rotation              = var.kms_enable_key_rotation
  cloudfront_log_cookies               = var.cloudfront_log_cookies
  cloudfront_price_class               = var.cloudfront_price_class
  cloudfront_enable_failover           = var.cloudfront_enable_failover
  use_cloudfront_domain                = var.use_cloudfront_domain
  tags                                 = var.tags
}
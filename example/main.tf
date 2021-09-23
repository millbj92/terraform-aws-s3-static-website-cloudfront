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

module "aws_s3_bucket_cloudfront" {
  source                   = "../"
  s3_bucket_name           = var.s3_bucket_name
  s3_enable_logging        = var.s3_enable_logging
  s3_use_bucket_encryption = var.s3_use_bucket_encryption
  kms_enable_key_rotation  = var.kms_enable_key_rotation
  s3_force_destroy         = var.s3_force_destroy
  use_cloudfront_domain    = var.use_cloudfront_domain
  tags                     = var.tags
}
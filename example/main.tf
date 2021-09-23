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
  source = "../"

  domain_name            = var.domain_name
  use_default_domain     = var.use_default_domain
  logging                = var.logging
  use_bucket_encryption  = var.use_bucket_encryption
  enable_key_rotation    = var.enable_key_rotation
  tags                   = var.tags
  deploy_redirect_bucket = var.deploy_redirect_bucket
  force_destroy          = var.force_destroy
}
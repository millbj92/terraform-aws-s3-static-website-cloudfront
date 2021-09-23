

provider "aws" {
  //This provider is needed as cloudfront needs us-east-1
  region = "us-east-1"
  alias  = "aws_cloudfront"
}

locals {
  domain_name = var.use_cloudfront_domain ? [] : [var.s3_bucket_name]
}
resource "aws_kms_key" "log_bucket" {
  count                   = var.s3_enable_logging && var.s3_use_bucket_encryption ? 1 : 0
  description             = "KMS Key for log bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = var.kms_enable_key_rotation
}

resource "aws_s3_bucket" "log_bucket" {
  count         = var.s3_enable_logging ? 1 : 0
  bucket        = "${var.s3_bucket_name}-logs"
  acl           = "log-delivery-write"
  tags          = var.tags
  force_destroy = var.s3_force_destroy
  versioning {
    enabled = true
  }

  dynamic "lifecycle_rule" {
    for_each = var.s3_enable_log_lifecycle ? [1] : []
    content {
      id      = "log"
      enabled = true
      prefix  = "website/"

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      dynamic "transition" {
        for_each = var.s3_log_transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = var.s3_logs_expire ? [1] : []
        content {
          days = var.s3_log_expiration_in_days
        }
      }
    }
  }
  dynamic "server_side_encryption_configuration" {
    for_each = var.s3_use_bucket_encryption ? [1] : [0]
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = aws_kms_key.log_bucket[0].arn
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}


resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = length(var.s3_cors_rules.allowed_headers) > 0 ? var.s3_cors_rules.allowed_headers : []
    allowed_methods = length(var.s3_cors_rules.allowed_methods) > 0 ? var.s3_cors_rules.allowed_methods : []
    allowed_origins = length(var.s3_cors_rules.allowed_origins) > 0 ? var.s3_cors_rules.allowed_origins : []
    expose_headers  = length(var.s3_cors_rules.expose_headers) > 0 ? var.s3_cors_rules.expose_headers : []
    max_age_seconds = var.s3_cors_rules.max_age_seconds
  }

  dynamic "logging" {
    for_each = var.s3_enable_logging == true ? [1] : []
    content {
      target_bucket = aws_s3_bucket.log_bucket[0].id
      target_prefix = "website/"
    }
  }

  policy = data.aws_iam_policy_document.s3_bucket_policy.json
  tags   = var.tags

  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${var.s3_bucket_name}.s3.amazonaws.com"
    origin_id   = "s3-cloudfront"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  dynamic "logging_config" {
    for_each = var.s3_enable_logging == true ? [1] : []
    content {
      include_cookies = var.cloudfront_log_cookies
      bucket          = aws_s3_bucket.log_bucket[0].bucket_domain_name
      prefix          = "cloudfront/"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = local.domain_name

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3-cloudfront"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.use_cloudfront_domain ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.use_cloudfront_domain ? [] : [1]
    content {
      acm_certificate_arn      = var.aws_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/"
  }

  wait_for_deployment = false
  tags                = var.tags
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.s3_bucket_name}.s3.amazonaws.com"
}
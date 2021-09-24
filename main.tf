
provider "aws" {
  region = var.region
}
provider "aws" {
  //This provider is needed as cloudfront needs us-east-1
  region = "us-east-1"
  alias  = "aws_cloudfront"
}

provider "aws" {
  region = var.s3_replication_region
  alias  = "aws_replication"
}

locals {
  domain_name = var.use_cloudfront_domain ? [] : [var.s3_primary_bucket_name]
  s3_redirect = var.s3_bucket_redirect != null || var.s3_routing_policy != null
}
resource "aws_kms_key" "log_bucket" {
  count                   = var.s3_enable_logging && var.s3_use_bucket_encryption ? 1 : 0
  description             = "KMS Key for log bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = var.kms_enable_key_rotation
  tags                    = var.tags
}

resource "aws_s3_bucket" "log_bucket" {
  count         = var.s3_enable_logging ? 1 : 0
  bucket        = "logs-${var.s3_primary_bucket_name}"
  acl           = "log-delivery-write"
  tags          = var.tags
  force_destroy = var.s3_force_destroy

  dynamic "lifecycle_rule" {
    for_each = var.s3_enable_log_lifecycle ? [1] : []
    content {
      id      = "log-${var.s3_primary_bucket_name}"
      enabled = true
      prefix  = ""

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

  tags_all = var.tags
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_primary_bucket_name}/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudfront_failover_policy" {
  statement {
    sid = "1"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::slot2-${var.s3_primary_bucket_name}/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

resource "aws_iam_role" "replication" {
  count = var.s3_enable_primary_bucket_replication == true ? 1 : 0
  name  = "${var.s3_primary_bucket_name}-replication-role"

  assume_role_policy = var.iam_assume_role_policy
  tags               = var.tags
}

resource "aws_iam_policy" "replication" {
  count = var.s3_enable_primary_bucket_replication == true ? 1 : 0
  name  = "${var.s3_primary_bucket_name}-replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3_bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.replication[0].arn}/*"
    }
  ]
}
POLICY

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "replication" {
  count      = var.s3_enable_primary_bucket_replication == true ? 1 : 0
  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

data "aws_canonical_user_id" "current_user" {}
resource "aws_s3_bucket" "replication" {
  count         = var.s3_enable_primary_bucket_replication == true ? 1 : 0
  bucket        = "slot2-${var.s3_primary_bucket_name}"
  force_destroy = var.s3_force_destroy
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

  dynamic "grant" {
    for_each = var.s3_acl_grant_canonical_user == true ? [1] : []
    content {
      id          = data.aws_canonical_user_id.current_user.id
      type        = "CanonicalUser"
      permissions = ["FULL_CONTROL"]
    }
  }

  dynamic "grant" {
    for_each = var.s3_primary_acl_grants
    content {
      id          = grant.value.id
      type        = grant.value.type
      permissions = grant.value.permissions
    }
  }

  dynamic "logging" {
    for_each = var.s3_enable_logging == true ? [1] : []
    content {
      target_bucket = aws_s3_bucket.log_bucket[0].id
      target_prefix = "slot2-${var.s3_primary_bucket_name}/"
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.s3_enable_primary_bucket_lifecycle == true ? [1] : []
    content {
      prefix  = ""
      enabled = true
      dynamic "noncurrent_version_transition" {
        for_each = var.s3_primary_version_transitions
        content {
          days          = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  dynamic "website" {
    for_each = var.s3_bucket_redirect == null && var.s3_routing_policy == null ? [1] : []
    content {
      index_document = "index.html"
    }
  }

  dynamic "website" {
    for_each = var.s3_bucket_redirect != null && var.s3_routing_policy == null ? [1] : []
    content {
      redirect_all_requests_to = var.s3_bucket_redirect
    }
  }
  dynamic "website" {
    for_each = var.s3_routing_policy != null && var.s3_bucket_redirect == null ? [1] : []
    content {
      index_document = "index.html"
      routing_rules  = var.s3_routing_policy
    }
  }

  policy = data.aws_iam_policy_document.cloudfront_failover_policy.json
  tags   = var.tags
}


resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.s3_primary_bucket_name
  acl           = var.s3_primary_bucket_acl
  force_destroy = var.s3_force_destroy
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

  dynamic "grant" {
    for_each = var.s3_acl_grant_canonical_user == true ? [1] : []
    content {
      id          = data.aws_canonical_user_id.current_user.id
      type        = "CanonicalUser"
      permissions = ["FULL_CONTROL"]
    }
  }

  dynamic "grant" {
    for_each = var.s3_primary_acl_grants
    content {
      id          = grant.value.id
      type        = grant.value.type
      permissions = grant.value.permissions
    }
  }

  dynamic "logging" {
    for_each = var.s3_enable_logging == true ? [1] : []
    content {
      target_bucket = aws_s3_bucket.log_bucket[0].id
      target_prefix = "${var.s3_primary_bucket_name}/"
    }
  }

  policy = data.aws_iam_policy_document.s3_bucket_policy.json
  tags   = var.tags

  dynamic "replication_configuration" {
    for_each = var.s3_enable_primary_bucket_replication == true || var.cloudfront_enable_failover == true ? [1] : []
    content {
      role = aws_iam_role.replication[0].arn

      rules {
        id     = ""
        prefix = ""
        status = "Enabled"

        destination {
          bucket        = aws_s3_bucket.replication[0].arn
          storage_class = "STANDARD"
        }
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.s3_enable_primary_bucket_lifecycle == true ? [1] : []
    content {
      prefix  = ""
      enabled = true
      dynamic "noncurrent_version_transition" {
        for_each = var.s3_primary_version_transitions
        content {
          days          = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  dynamic "website" {
    for_each = var.s3_bucket_redirect == null && var.s3_routing_policy == null ? [1] : []
    content {
      index_document = "index.html"
    }
  }

  dynamic "website" {
    for_each = var.s3_bucket_redirect != null && var.s3_routing_policy == null ? [1] : []
    content {
      redirect_all_requests_to = var.s3_bucket_redirect
    }
  }
  dynamic "website" {
    for_each = var.s3_routing_policy != null && var.s3_bucket_redirect == null ? [1] : []
    content {
      index_document = "index.html"
      routing_rules  = var.s3_routing_policy
    }
  }
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  dynamic "origin_group" {
    for_each = var.cloudfront_enable_failover == true ? [1] : []
    content {
      origin_id = "${var.s3_primary_bucket_name}-failover-group"

      failover_criteria {
        status_codes = [403, 404, 500, 502]
      }

      member {
        origin_id = "${var.s3_primary_bucket_name}-cloudfront-primary"
      }

      member {
        origin_id = "${var.s3_primary_bucket_name}-cloudfront-failover"
      }
    }
  }
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "${var.s3_primary_bucket_name}-cloudfront-primary"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  dynamic "origin" {
    for_each = var.cloudfront_enable_failover == true ? [1] : []

    content {
      domain_name = aws_s3_bucket.replication[0].bucket_regional_domain_name
      origin_id   = "${var.s3_primary_bucket_name}-cloudfront-failover"

      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity2.cloudfront_access_identity_path
      }
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

    target_origin_id = "${var.s3_primary_bucket_name}-failover-group"

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
  comment = "access-identity-${var.s3_primary_bucket_name}.s3.amazonaws.com"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity2" {
  comment = "access-identity-${var.s3_primary_bucket_name}.s3.amazonaws.com"
}
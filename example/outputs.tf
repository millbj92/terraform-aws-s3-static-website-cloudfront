
output "s3_cloudfront_domain_name" {
  value       = module.aws_s3_bucket_cloudfront.s3_primary_domain_name
  description = "URL to the cloudfront distrobution of the primary bucket."
}

output "s3_primary_bucket_url" {
  value       = var.s3_primary_bucket_name
  description = "URL for the primary bucket."
}

output "s3_bucket_arn" {
  value       = module.aws_s3_bucket_cloudfront.s3_primary_bucket_arn
  description = "The arn of the created s3 website bucket."
}

output "s3_bucket_name" {
  value       = module.aws_s3_bucket_cloudfront.s3_primary_bucket_name
  description = "The name of the created s3 website bucket."
}

output "s3_log_bucket_arn" {
  value       = module.aws_s3_bucket_cloudfront.s3_log_bucket_arn
  description = "The arn of the created s3 logging bucket."
}

output "s3_log_bucket_name" {
  value       = module.aws_s3_bucket_cloudfront.s3_log_bucket_name
  description = "The name of the created s3 logging bucket"
}
output "s3_log_domain_name" {
  value       = module.aws_s3_bucket_cloudfront.s3_log_domain_name
  description = "The fully qualified domain name of the log bucket."
}
output "log_bucket_KMS_key_arn" {
  value       = module.aws_s3_bucket_cloudfront.log_bucket_KMS_key_arn
  description = "The arn of the created KMS key for the logging bucket. Used for encrypting/decrypting the bucket."
}

output "replication_bucket_arn" {
  value       = module.aws_s3_bucket_cloudfront.replication_bucket_arn
  description = "The arn of the replication bucket"
}
output "replication_bucket_name" {
  value       = module.aws_s3_bucket_cloudfront.replication_bucket_name
  description = "The name of the replication bucket."
}
output "replication_bucket_domain_name" {
  value       = module.aws_s3_bucket_cloudfront.replication_bucket_domain_name
  description = "The replication buckets domain name."
}
output "cloudfront_domain_name" {
  value       = module.aws_s3_bucket_cloudfront.cloudfront_domain_name
  description = "The domain name used by your cloudfront distribution. If you are using the 'default_domain' variable, you would use this."
}

output "cloudfront_dist_id" {
  value       = module.aws_s3_bucket_cloudfront.cloudfront_dist_id
  description = "Cloudfront Distribution ID for this site."
}

output "cloudfront_zone_id" {
  value       = module.aws_s3_bucket_cloudfront.cloudfront_zone_id
  description = "ID of the Hosted Zone that Cloudfront is connected to."
}
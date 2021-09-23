
output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "The domain name used by your cloudfront distribution."
}
output "cloudfront_dist_id" {
  value       = aws_cloudfront_distribution.s3_distribution.id
  description = "Cloudfront Distribution ID for this site."
}
output "cloudfront_zone_id" {
  value       = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
  description = "ID of the Hosted Zone that Cloudfront is connected to."
}
output "s3_primary_bucket_arn" {
  value       = aws_s3_bucket.s3_bucket.arn
  description = "The arn of the created s3 website bucket."
}
output "s3_primary_bucket_name" {
  value       = var.s3_primary_bucket_name
  description = "Returns the s3_primary_bucket_name variable for reference."
}
output "s3_primary_domain_name" {
  value       = aws_s3_bucket.s3_bucket.website_domain
  description = "The fully qualified domain name of your S3 bucket. For reference only."
}
output "s3_log_bucket_arn" {
  value       = aws_s3_bucket.log_bucket[0].arn
  description = "The arn of the created s3 logging bucket."
}
output "s3_log_bucket_name" {
  value       = aws_s3_bucket.log_bucket[0].id
  description = "The name of the created s3 logging bucket"
}
output "s3_log_domain_name" {
  value       = aws_s3_bucket.log_bucket[0].bucket_domain_name
  description = "The fully qualified domain name of your logging bucket"
}
output "log_bucket_KMS_key_arn" {
  value       = aws_kms_key.log_bucket[0].arn
  description = "The arn of the created KMS encryption key that encrypts your logs. Recommended you jot this ARN down in case you ever need to decrypt your logs."
}
output "replication_bucket_arn" {
  value       = aws_s3_bucket.replication[0].arn
  description = "The arn of the replication bucket"
}
output "replication_bucket_name" {
  value       = aws_s3_bucket.replication[0].id
  description = "The name of the replication bucket."
}
output "replication_bucket_domain_name" {
  value       = aws_s3_bucket.replication[0].website_domain
  description = "The replication buckets domain name."
}
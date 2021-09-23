# S3_Bucket_And_Cloudfront

This module allows the creation of a static S3 website, with Cloudfront as the CDN, without ACM configurations. This is useful when you want to host files, or a website, over a CDN but don't necessarily need a domain name.

 Optionally you can also use this module to:
  - Enable KMS encryption on your S3 buckets
  - Enable KMS key rotation.
  - Enable access logging for buckets and Cloudfront.

 Usage:

 Example of 's3_static_website" module in `main.tf`.
 **Note:** I am putting the values in the below snippet to show you example values. It's a good practice to put your values into variables, like I am doing [here](./example/main.tf)

 ```hcl
  module "s3_static_website" {
  source                 = "millbj92/s3-static-website-cloudfront/aws"
  domain_name            = "dev.example.com"
  hosted_zone            = "example.com"
  acm_certificate_domain = "*.abc.example.com"
  use_default_domain     = false
  logging                = true
  use_bucket_encryption  = true
  enable_key_rotation    = true
  tags                   = var.tags
}
 ```

 *Please Note* While I have tried to follow the best security practices out-of-the-box, there is still some recommended setup. Please consider creating a WAF ([Web application Firewall](https://aws.amazon.com/waf/)) in front of your cloudfront distribution. It is highly recommended that you use one, especially in a production environment. That said, WAF's are very situation-specific, so I cannot guess how your setup should behave.
 [WAF Terraform Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl). Last but not least, you may also want to add a Lambda@Edge function between cloudfront and your bucket, to add an extra layer of security headers.

   #### Running the module

 To run the module, simply plug in the values below into a .tfvars file or export the equivalent env variables, and run the below commands

   - `terraform init`
   - `terraform plan` (make sure you like what you see on the console before going to the next step!)
   - `terraform apply`

&nbsp;
## Documentation
&nbsp;
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
#### Requirements

No requirements.

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a |

#### Modules

No modules.

#### Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.s3_distribution2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_kms_key.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.s3_www_bucket2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_iam_policy_document.s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_bucket_policy2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_domain_name"></a> [domain_name](#input_domain_name) | Domain name. Must be unique, and already registered. | `string` |
| <a name="input_aws_certificate_arn"></a> [aws_certificate_arn](#input_aws_certificate_arn) | SSL Certificate used to link the Cloudfront resource to the dns record. | `string` |
| <a name="input_deploy_redirect_bucket"></a> [deploy_redirect_bucket](#input_deploy_redirect_bucket) | Set this to true to deploy a bucket what will redirect from www to non-www | `bool` |
| <a name="input_enable_key_rotation"></a> [enable_key_rotation](#input_enable_key_rotation) | Set this to true in order to enable key rotation. Only works if use_bucket_encryption is true. Recommend setting to true so you don't get locked out of your buckets! | `bool` |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy) | This value will force-delete your buckets with files sill inside. You have been warned. Do not use in Prod. | `bool` |
| <a name="input_log_cookies"></a> [log_cookies](#input_log_cookies) | Log cookies in cloudfront. Only works in logging is true. | `bool` |
| <a name="input_logging"></a> [logging](#input_logging) | Use logging for resources. Will create an extra bucket. | `bool` |
| <a name="input_price_class"></a> [price_class](#input_price_class) | CloudFront distribution price class | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to set on the resources. | `map(string)` |
| <a name="input_use_bucket_encryption"></a> [use_bucket_encryption](#input_use_bucket_encryption) | Set this to true to encrypt your buckets with a KMS key. | `bool` |
| <a name="input_use_default_domain"></a> [use_default_domain](#input_use_default_domain) | Use CloudFront website address without Route53 and ACM certificate | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_dist_id"></a> [cloudfront_dist_id](#output_cloudfront_dist_id) | Cloudfront Distribution ID for this site. |
| <a name="output_cloudfront_domain_name"></a> [cloudfront_domain_name](#output_cloudfront_domain_name) | The domain name used by your cloudfront distribution. If you are using the 'default_domain' variable, you would use this. |
| <a name="output_cloudfront_zone_id"></a> [cloudfront_zone_id](#output_cloudfront_zone_id) | ID of the Hosted Zone that Cloudfront is connected to. |
| <a name="output_log_bucket_KMS_key_arn"></a> [log_bucket_KMS_key_arn](#output_log_bucket_KMS_key_arn) | The arn of the created KMS key for the logging bucket. Used for encrypting/decrypting the bucket. |
| <a name="output_s3_bucket_arn"></a> [s3_bucket_arn](#output_s3_bucket_arn) | The arn of the created s3 website bucket. |
| <a name="output_s3_bucket_name"></a> [s3_bucket_name](#output_s3_bucket_name) | The name of the created s3 website bucket. |
| <a name="output_s3_domain_name"></a> [s3_domain_name](#output_s3_domain_name) | The domain name of your S3 bucket. For reference only. Either use the Cloudfront Distrobution, or 'website_address' output. |
| <a name="output_s3_log_bucket_arn"></a> [s3_log_bucket_arn](#output_s3_log_bucket_arn) | The arn of the created s3 logging bucket. |
| <a name="output_s3_log_bucket_name"></a> [s3_log_bucket_name](#output_s3_log_bucket_name) | The name of the created s3 logging bucket |
| <a name="output_website_address"></a> [website_address](#output_website_address) | If not using the 'default_domain' variable, this will return your Route53 domain name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
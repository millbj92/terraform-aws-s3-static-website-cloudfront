# S3_Bucket_And_Cloudfront

This module allows the creation of a static S3 website, with Cloudfront as the CDN, without ACM configurations. This is useful when you want to host files, or a website, over a CDN but don't necessarily need a domain name.

 Optionally you can also use this module to:
  - Enable KMS encryption on your S3 buckets
  - Enable KMS key rotation.
  - Enable access logging for buckets and Cloudfront.
  - Configure custom ACL for buckets
  - Enable replication of buckets
  - Enable versioning on primary and replication buckets
  - Enable lifecycle events for the primary and replication buckets, to archive and eventually delete versioned data.
  - Enable failover on Cloudfront to your replication bucket whenever an error occurs on the primary.
 ### Usage:

 **Note:** I am putting the values in the below snippet to show you example values. Almost all them except for 's3_primary_bucket_name' have reasonable defaults. It's a good practice to put your values into a .tfvars file and project them to the module, like I am doing [here](./example/main.tf)

 ```hcl
  module "s3_static_website" {
  source                               = "millbj92/s3-static-website-cloudfront/aws"
  s3_primary_bucket_name               = "myorg-cdn-distribution-12345"
  s3_enable_logging                    = true
  s3_enable_primary_bucket_lifecycle   = true
  s3_enable_primary_bucket_replication = true
  s3_replication_region                = "us-west-1"
  s3_acl_grant_canonical_user          = false
  s3_primary_bucket_acl                = "private"
  s3_primary_acl_grants                = null
  s3_routing_policy                    = null # To load a routing file: data.local_file.routing_rules_input.content
  s3_enable_log_lifecycle              = true
  s3_bucket_redirect                   = null
  s3_primary_version_transitions       = [{
                                            days          = 30,
                                            storage_class = "STANDARD_IA",
                                          },
                                          {
                                            days          = 60,
                                            storage_class = "GLACIER",
                                          }]
  s3_primary_version_expiration        = 120
  s3_log_transitions                   = var.s3_log_transitions
  s3_logs_expire                       = var.s3_logs_expire
  s3_log_expiration_in_days            = var.s3_log_expiration_in_days
  s3_use_bucket_encryption             = true
  s3_cors_rules                        = {allowed_headers = ["*"],
                                          allowed_methods = ["GET"],
                                          allowed_origins = ["*"],
                                          expose_headers  = ["ETag"],
                                          max_age_seconds = 3000}
  s3_force_destroy                     = false
  iam_assume_role_policy               = data.local_file.iam_assume_role_policy.content
  kms_enable_key_rotation              = true
  cloudfront_log_cookies               = false
  cloudfront_price_class               = "PriceClass_100"
  cloudfront_enable_failover           = true
  use_cloudfront_domain                = true
  tags                                 = var.tags
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
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_iam_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_canonical_user_id.current_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.cloudfront_failover_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_primary_bucket_name"></a> [s3\_primary\_bucket\_name](#input\_s3\_primary\_bucket\_name) | Name of the bucket to be deployed | `string` | n/a | yes |
| <a name="input_aws_certificate_arn"></a> [aws\_certificate\_arn](#input\_aws\_certificate\_arn) | SSL Certificate used to link the Cloudfront resource to the dns record. | `string` | `null` | no |
| <a name="input_cloudfront_enable_failover"></a> [cloudfront\_enable\_failover](#input\_cloudfront\_enable\_failover) | Enable failover functionality with cloudfront | `bool` | `true` | no |
| <a name="input_cloudfront_log_cookies"></a> [cloudfront\_log\_cookies](#input\_cloudfront\_log\_cookies) | Log cookies in cloudfront. Only works in logging is true. | `bool` | `false` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | CloudFront distribution price class | `string` | `"PriceClass_100"` | no |
| <a name="input_iam_assume_role_policy"></a> [iam\_assume\_role\_policy](#input\_iam\_assume\_role\_policy) | Role policy definition for assuming a role capable of enabling replication in another region. | `string` | `null` | no |
| <a name="input_kms_enable_key_rotation"></a> [kms\_enable\_key\_rotation](#input\_kms\_enable\_key\_rotation) | Set this to true in order to enable key rotation. Only works if use\_bucket\_encryption is true. Recommend setting to true so you don't get locked out of your buckets! | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Primary AWS region | `string` | `"us-east-1"` | no |
| <a name="input_s3_acl_grant_canonical_user"></a> [s3\_acl\_grant\_canonical\_user](#input\_s3\_acl\_grant\_canonical\_user) | Find the canonical user id of the current acount and add it to the ACL. | `bool` | `false` | no |
| <a name="input_s3_bucket_redirect"></a> [s3\_bucket\_redirect](#input\_s3\_bucket\_redirect) | Setting this string will make your s3 bucket redirect to the specified url. Used as a global redirect - this setting will redirect to another hostname no matter what. If you'd like more control, use the s3\_routing\_policy variable. | `string` | `null` | no |
| <a name="input_s3_cors_rules"></a> [s3\_cors\_rules](#input\_s3\_cors\_rules) | Cross Origin Resource Sharing configurations for the primary and replication buckets. | <pre>object({<br>    allowed_headers = list(string),<br>    allowed_methods = list(string),<br>    allowed_origins = list(string),<br>    expose_headers  = list(string),<br>    max_age_seconds = number<br>  })</pre> | <pre>{<br>  "allowed_headers": [<br>    "*"<br>  ],<br>  "allowed_methods": [<br>    "GET"<br>  ],<br>  "allowed_origins": [<br>    "*"<br>  ],<br>  "expose_headers": [<br>    "ETag"<br>  ],<br>  "max_age_seconds": 3000<br>}</pre> | no |
| <a name="input_s3_enable_log_lifecycle"></a> [s3\_enable\_log\_lifecycle](#input\_s3\_enable\_log\_lifecycle) | Enable lifecycle rules on log buckets for archiving data. | `bool` | `true` | no |
| <a name="input_s3_enable_logging"></a> [s3\_enable\_logging](#input\_s3\_enable\_logging) | Use logging for resources. Will create an extra bucket. | `bool` | `true` | no |
| <a name="input_s3_enable_primary_bucket_lifecycle"></a> [s3\_enable\_primary\_bucket\_lifecycle](#input\_s3\_enable\_primary\_bucket\_lifecycle) | Enable lifecycle rules for primary buckets. This will only effect previous versions of the bucket, and not the live data. | `bool` | `true` | no |
| <a name="input_s3_enable_primary_bucket_replication"></a> [s3\_enable\_primary\_bucket\_replication](#input\_s3\_enable\_primary\_bucket\_replication) | Replicate your primary bucket to another region. Recommended setting to true, as this promotes redundancy and lowers the blast radius if your bucket gets deleted. | `bool` | `true` | no |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | This value will force-delete your buckets with files sill inside. You have been warned. Do not use in Prod. | `bool` | `false` | no |
| <a name="input_s3_log_expiration_in_days"></a> [s3\_log\_expiration\_in\_days](#input\_s3\_log\_expiration\_in\_days) | The number of days a log file has to live before expiration and permanent deletion. | `number` | `90` | no |
| <a name="input_s3_log_transitions"></a> [s3\_log\_transitions](#input\_s3\_log\_transitions) | When log lifecycles are enabled, describe their transitions.  Use DEEP\_ARCHIVE if you plan on keeping data for 7-10 years or more. Good for meeting compliance. | <pre>set(object({<br>    days          = number,<br>    storage_class = string<br>  }))</pre> | <pre>[<br>  {<br>    "days": 30,<br>    "storage_class": "STANDARD_IA"<br>  },<br>  {<br>    "days": 60,<br>    "storage_class": "GLACIER"<br>  }<br>]</pre> | no |
| <a name="input_s3_logs_expire"></a> [s3\_logs\_expire](#input\_s3\_logs\_expire) | Set to true if you want logs to eventually expire. | `bool` | `true` | no |
| <a name="input_s3_primary_acl_grants"></a> [s3\_primary\_acl\_grants](#input\_s3\_primary\_acl\_grants) | Custom Access Control List grants for primary and replication buckets. Conflicts with 's3\_primary\_bucket\_acl'. | <pre>set(object({<br>    id           = string<br>    type         = string<br>    permissions  = list(string)<br>    uri          = string<br>    emailAddress = string<br>  }))</pre> | `[]` | no |
| <a name="input_s3_primary_bucket_acl"></a> [s3\_primary\_bucket\_acl](#input\_s3\_primary\_bucket\_acl) | Access Control List of the primary bucket. Setting it to anything above private is not recommended. | `string` | `"private"` | no |
| <a name="input_s3_primary_version_expiration"></a> [s3\_primary\_version\_expiration](#input\_s3\_primary\_version\_expiration) | The time it takes, in days, for non-current versioned files to expire. | `number` | `120` | no |
| <a name="input_s3_primary_version_transitions"></a> [s3\_primary\_version\_transitions](#input\_s3\_primary\_version\_transitions) | Back up previous versions of all files into a glacier account after a specified amount of time. | <pre>set(object({<br>    days          = number,<br>    storage_class = string<br>  }))</pre> | <pre>[<br>  {<br>    "days": 30,<br>    "storage_class": "STANDARD_IA"<br>  },<br>  {<br>    "days": 100,<br>    "storage_class": "GLACIER"<br>  }<br>]</pre> | no |
| <a name="input_s3_replication_region"></a> [s3\_replication\_region](#input\_s3\_replication\_region) | The region your primary bucket will replicate to. | `string` | `"us-west-1"` | no |
| <a name="input_s3_routing_policy"></a> [s3\_routing\_policy](#input\_s3\_routing\_policy) | s3 bucket routing policy, defined in json, or EOF format. Used for setting fine-tuned redirects from one sub-directory to another, or to another host altogether. | `string` | `null` | no |
| <a name="input_s3_use_bucket_encryption"></a> [s3\_use\_bucket\_encryption](#input\_s3\_use\_bucket\_encryption) | Set this to true to encrypt your buckets with a KMS key. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set on the resources. | `map(string)` | `{}` | no |
| <a name="input_use_cloudfront_domain"></a> [use\_cloudfront\_domain](#input\_use\_cloudfront\_domain) | Use CloudFront primary address without Route53 and ACM certificate | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_dist_id"></a> [cloudfront\_dist\_id](#output\_cloudfront\_dist\_id) | Cloudfront Distribution ID for this site. |
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | The domain name used by your cloudfront distribution. |
| <a name="output_cloudfront_zone_id"></a> [cloudfront\_zone\_id](#output\_cloudfront\_zone\_id) | ID of the Hosted Zone that Cloudfront is connected to. |
| <a name="output_log_bucket_KMS_key_arn"></a> [log\_bucket\_KMS\_key\_arn](#output\_log\_bucket\_KMS\_key\_arn) | The arn of the created KMS encryption key that encrypts your logs. Recommended you jot this ARN down in case you ever need to decrypt your logs. |
| <a name="output_replication_bucket_arn"></a> [replication\_bucket\_arn](#output\_replication\_bucket\_arn) | The arn of the replication bucket |
| <a name="output_replication_bucket_domain_name"></a> [replication\_bucket\_domain\_name](#output\_replication\_bucket\_domain\_name) | The replication buckets domain name. |
| <a name="output_replication_bucket_name"></a> [replication\_bucket\_name](#output\_replication\_bucket\_name) | The name of the replication bucket. |
| <a name="output_s3_log_bucket_arn"></a> [s3\_log\_bucket\_arn](#output\_s3\_log\_bucket\_arn) | The arn of the created s3 logging bucket. |
| <a name="output_s3_log_bucket_name"></a> [s3\_log\_bucket\_name](#output\_s3\_log\_bucket\_name) | The name of the created s3 logging bucket |
| <a name="output_s3_log_domain_name"></a> [s3\_log\_domain\_name](#output\_s3\_log\_domain\_name) | The fully qualified domain name of your logging bucket |
| <a name="output_s3_primary_bucket_arn"></a> [s3\_primary\_bucket\_arn](#output\_s3\_primary\_bucket\_arn) | The arn of the created s3 website bucket. |
| <a name="output_s3_primary_bucket_name"></a> [s3\_primary\_bucket\_name](#output\_s3\_primary\_bucket\_name) | Returns the s3\_primary\_bucket\_name variable for reference. |
| <a name="output_s3_primary_domain_name"></a> [s3\_primary\_domain\_name](#output\_s3\_primary\_domain\_name) | The fully qualified domain name of your S3 bucket. For reference only. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
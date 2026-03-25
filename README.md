# opentofu-module-aws-github-oidc-sub-account
Managed by github-org-manager

<!-- BEGIN_TF_DOCS -->
# opentofu-module-aws-github-oidc-sub-account
Managed by github-org-manager

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.s3_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.s3_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | ARN of the role to assume in the sub-account (used to configure the AWS provider) | `string` | n/a | yes |
| <a name="input_custom_roles"></a> [custom\_roles](#input\_custom\_roles) | Custom roles to create in this sub-account | <pre>map(object({<br/>    role_name          = string<br/>    policy_arns        = list(string)<br/>    inline_policy      = optional(string)<br/>    trusted_oidc_repos = list(string)<br/>    oidc_role_arns     = map(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the sub-account provider | `string` | n/a | yes |
| <a name="input_repos"></a> [repos](#input\_repos) | Map of repo name to config for repos whose state lives in this account | <pre>map(object({<br/>    s3_state_role_name = string<br/>    oidc_role_arn      = string<br/>    state_prefix       = string<br/>    tags               = map(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_role_arns"></a> [custom\_role\_arns](#output\_custom\_role\_arns) | Map of custom role key to role ARN |
| <a name="output_custom_role_names"></a> [custom\_role\_names](#output\_custom\_role\_names) | Map of custom role key to role name |
| <a name="output_s3_state_role_arns"></a> [s3\_state\_role\_arns](#output\_s3\_state\_role\_arns) | Map of repo name to S3 state role ARN |
| <a name="output_s3_state_role_names"></a> [s3\_state\_role\_names](#output\_s3\_state\_role\_names) | Map of repo name to S3 state role name |
<!-- END_TF_DOCS -->
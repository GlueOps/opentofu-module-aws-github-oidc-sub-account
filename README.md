# opentofu-module-aws-github-oidc-sub-account
Managed by github-org-manager

<!-- BEGIN_TF_DOCS -->
# opentofu-module-aws-github-oidc-sub-account

OpenTofu module that creates scoped IAM roles in AWS sub-accounts for GitHub Actions OIDC workflows. Creates per-repo S3 state roles (locked to each repo's state file prefix) and optional custom roles with configurable managed and inline policies.

## How it works

This module is the second half of a two-module setup:

1. **[opentofu-module-aws-github-oidc](https://github.com/GlueOps/opentofu-module-aws-github-oidc)** — runs in the AWS management account. Creates the GitHub OIDC provider and per-repo IAM roles.

2. **This module** (`opentofu-module-aws-github-oidc-sub-account`) — runs in each AWS sub-account. Called once per sub-account with `for_each`, receiving the provider from the caller via `configuration_aliases`.

```
Management Account OIDC Role
  |
  | (sts:AssumeRole)
  v
Sub-Account (this module)
  ├── S3 State Role ──> scoped to: s3:::*/{org}/{repo}/*
  └── Custom Roles  ──> configurable managed + inline policies
```

## Usage

```hcl
provider "aws" {
  alias    = "sub_account"
  for_each = local.sub_account_config
  region   = each.value.region
  assume_role {
    role_arn = "arn:aws:iam::${each.value.account_id}:role/OrganizationAccountAccessRole"
  }
}

module "github_oidc_sub_account" {
  source   = "git::https://github.com/GlueOps/opentofu-module-aws-github-oidc-sub-account.git?ref=main"
  for_each = toset(keys(local.sub_account_config))

  providers = { aws = aws.sub_account[each.key] }

  repos = { for repo, cfg in local.github_repos : repo => {
    s3_state_role_name = module.github_oidc.s3_state_role_names[repo]
    oidc_role_arn      = module.github_oidc.oidc_role_arns[repo]
    state_prefix       = module.github_oidc.state_prefixes[repo]
    tags               = module.github_oidc.tags[repo]
  } if cfg.state_account == each.key }

  custom_roles = { for key, cfg in local.custom_roles : key => {
    role_name          = module.github_oidc.custom_role_names[key]
    policy_arns        = cfg.policy_arns
    inline_policy      = cfg.inline_policy
    trusted_oidc_repos = cfg.trusted_oidc_repos
    oidc_role_arns     = module.github_oidc.oidc_role_arns
  } if cfg.account == each.key }
}
```

## What it creates

### S3 state roles (per repo)

Each repo gets a role scoped to its own state file prefix:

- `s3:GetObject` and `s3:PutObject` on `arn:aws:s3:::*/{org}/{repo}/*`
- `s3:ListBucket` on `arn:aws:s3:::*` with prefix condition

Trust policy: only the repo's corresponding OIDC role in the management account can assume it.

### Custom roles

Configurable roles with:
- Managed policy attachments (e.g., `AmazonRoute53FullAccess`)
- Optional inline policies for fine-grained access
- Trust policy scoped to specified OIDC repos

## Provider handling

This module uses `configuration_aliases` — it does **not** create its own AWS provider. The caller defines providers with `for_each` and passes them in:

```hcl
providers = { aws = aws.sub_account[each.key] }
```

This allows the module to be used with `for_each` across multiple sub-accounts.

## Deleting a sub-account

Two-step process:

1. Remove all repos and custom roles that reference the account from the module inputs. Apply.
2. Remove the module call and provider for that account. Apply.

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
| <a name="input_custom_roles"></a> [custom\_roles](#input\_custom\_roles) | Custom roles to create in this sub-account | <pre>map(object({<br/>    role_name          = string<br/>    policy_arns        = list(string)<br/>    inline_policy      = optional(string)<br/>    trusted_oidc_repos = list(string)<br/>    oidc_role_arns     = map(string)<br/>  }))</pre> | `{}` | no |
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
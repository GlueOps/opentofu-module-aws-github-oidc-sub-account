variable "assume_role_arn" {
  description = "ARN of the role to assume in the sub-account (used to configure the AWS provider)"
  type        = string
}

variable "region" {
  description = "AWS region for the sub-account provider"
  type        = string
}

variable "repos" {
  description = "Map of repo name to config for repos whose state lives in this account"
  type = map(object({
    s3_state_role_name = string
    oidc_role_arn      = string
    state_prefix       = string
    tags               = map(string)
  }))
  default = {}
}

variable "custom_roles" {
  description = "Custom roles to create in this sub-account"
  type = map(object({
    role_name          = string
    policy_arns        = list(string)
    inline_policy      = optional(string)
    trusted_oidc_repos = list(string)
    oidc_role_arns     = map(string)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

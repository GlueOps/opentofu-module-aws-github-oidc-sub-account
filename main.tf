provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.assume_role_arn
  }
}

# --- Scoped S3 state roles ---

resource "aws_iam_role" "s3_state" {
  for_each = var.repos
  name     = each.value.s3_state_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = each.value.oidc_role_arn }
    }]
  })

  tags = each.value.tags
}

resource "aws_iam_role_policy" "s3_state" {
  for_each = var.repos

  name = "s3-state-access"
  role = aws_iam_role.s3_state[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::*/${each.value.state_prefix}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::*"
        Condition = {
          StringLike = {
            "s3:prefix" = ["${each.value.state_prefix}/*"]
          }
        }
      }
    ]
  })
}

# --- Custom roles ---

resource "aws_iam_role" "custom" {
  for_each = var.custom_roles
  name     = each.value.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = [for repo in each.value.trusted_oidc_repos : each.value.oidc_role_arns[repo]] }
    }]
  })

  tags = merge(
    { ManagedBy = "opentofu", Purpose = "github-actions-oidc-custom" },
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = { for pair in flatten([
    for key, cfg in var.custom_roles : [
      for arn in cfg.policy_arns : { key = "${key}--${arn}", role_key = key, arn = arn }
    ]
  ]) : pair.key => pair }

  role       = aws_iam_role.custom[each.value.role_key].name
  policy_arn = each.value.arn
}

resource "aws_iam_role_policy" "custom" {
  for_each = { for key, cfg in var.custom_roles : key => cfg if cfg.inline_policy != null }

  name   = "custom-inline-policy"
  role   = aws_iam_role.custom[each.key].id
  policy = each.value.inline_policy
}

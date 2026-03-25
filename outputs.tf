output "s3_state_role_arns" {
  description = "Map of repo name to S3 state role ARN"
  value       = { for repo, role in aws_iam_role.s3_state : repo => role.arn }
}

output "s3_state_role_names" {
  description = "Map of repo name to S3 state role name"
  value       = { for repo, role in aws_iam_role.s3_state : repo => role.name }
}

output "custom_role_arns" {
  description = "Map of custom role key to role ARN"
  value       = { for key, role in aws_iam_role.custom : key => role.arn }
}

output "custom_role_names" {
  description = "Map of custom role key to role name"
  value       = { for key, role in aws_iam_role.custom : key => role.name }
}

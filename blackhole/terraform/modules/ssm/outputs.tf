output "ssm_parameter_arns" {
  value = { for k, v in data.aws_ssm_parameter.app_secrets : k => v.arn }
}
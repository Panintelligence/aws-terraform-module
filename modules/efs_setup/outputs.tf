output "lambda_role" {
  value = aws_iam_role.dashboard_prep
}

output "lambda_function" {
  value = aws_lambda_function.dashboard_prep
}

output "lambda_security_group" {
  value = aws_security_group.dashboard_prep
}

output "lambda_efs_access_point" {
  value = aws_efs_access_point.access_point_for_lambda
}
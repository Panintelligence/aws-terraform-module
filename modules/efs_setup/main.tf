data "aws_subnet" "private_subnet" {
  id = var.application_subnet_ids[0]
}


resource "aws_efs_access_point" "access_point_for_lambda" {
  file_system_id = var.dashboard_efs_id

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
  }

  posix_user {
    gid = 0
    uid = 0
  }
  tags = {
    Name = "${var.deployment_name}-lambda-efs-access-point"
  }
}

resource "aws_cloudwatch_log_group" "dashboard_prep" {
  name              = "/aws/lambda/${var.deployment_name}-dashboard-prep"
  retention_in_days = 14
}

resource "aws_lambda_function" "dashboard_prep" {
  filename      = "${path.module}/files/dashboard_prep.zip"
  function_name = "${var.deployment_name}-dashboard-prep"
  role          = aws_iam_role.dashboard_prep.arn
  handler       = "dashboard_prep.lambda_handler"

  runtime          = "python3.13"
  source_code_hash = filebase64sha256("${path.module}/files/dashboard_prep.zip")

  vpc_config {
    subnet_ids         = var.application_subnet_ids
    security_group_ids = [aws_security_group.dashboard_prep.id]
  }
  file_system_config {
    arn              = aws_efs_access_point.access_point_for_lambda.arn
    local_mount_path = "/mnt/efs"
  }

  memory_size = 512
  timeout     = 30
  depends_on  = [aws_cloudwatch_log_group.dashboard_prep]
}

resource "aws_lambda_invocation" "dashboard_prep" {
  function_name = aws_lambda_function.dashboard_prep.function_name
  input         = jsonencode({})
}

resource "aws_security_group" "dashboard_prep" {
  name        = "${var.deployment_name}-dashboard_prep"
  description = "Outbound to ${var.deployment_name} dashboard efs"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id


  egress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.efs_security_group_id]
  }
  tags = {
    Name = "${var.deployment_name}-dashboard-efs-prep-lambda"
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs" {
  security_group_id            = var.efs_security_group_id
  description                  = "Allow traffic from  ${var.deployment_name} lambda to EFS"
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
  referenced_security_group_id = aws_security_group.dashboard_prep.id

}
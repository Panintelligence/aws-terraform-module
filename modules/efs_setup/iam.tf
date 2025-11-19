data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement  {
    actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
      effect = "Allow"
    }
}


resource "aws_iam_role" "dashboard_prep" {
  name = "${var.deployment_name}-dashboard-efs-prep-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}



resource "aws_iam_role_policy_attachment" "vpc_lambda_dashboard_cleanup" {
  role = aws_iam_role.dashboard_prep.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


data "aws_iam_policy_document" "basic_lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "basic_lambda_logging" {
  name = "${var.deployment_name}-dashboard-efs-prep-lambda-logging"
  description = "Allow lambda function to log to cloudwatch"

  policy = data.aws_iam_policy_document.basic_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role = aws_iam_role.dashboard_prep.name
  policy_arn = aws_iam_policy.basic_lambda_logging.arn
}

# Configure the AWS Provider for the specific region
provider "aws" {
  region = var.aws_region
  alias  = "region"
}

# IAM Role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  provider = aws.region
  name     = "log_retention_lambda_role_${var.aws_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "log_retention_lambda_role"
    Environment = "all"
  }
}

# IAM Policy for CloudWatch Logs access
resource "aws_iam_policy" "lambda_policy" {
  provider    = aws.region
  name        = "log_retention_lambda_policy_${var.aws_region}"
  description = "IAM policy for log retention Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/log_retention_lambda_${var.aws_region}:*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  provider   = aws.region
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/log_retention_lambda_${var.aws_region}"
  retention_in_days = 14
}

# Create a zip file of the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda_function.zip"
}


# Lambda function
resource "aws_lambda_function" "log_retention_lambda" {
  provider      = aws.region
  function_name = "log_retention_lambda_${var.aws_region}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300 # 5 minutes
  memory_size   = 128


  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = {
    Name        = "log_retention_lambda"
    Environment = "all"
  }
}

# CloudWatch Event Rule to trigger the Lambda function daily
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  provider            = aws.region
  name                = "trigger_log_retention_lambda_daily_${var.aws_region}"
  description         = "Triggers the log retention Lambda function once a day"
  schedule_expression = "rate(7 days)"
}

# CloudWatch Event Target to connect the rule to the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  provider = aws.region
  rule     = aws_cloudwatch_event_rule.daily_trigger.name
  arn      = aws_lambda_function.log_retention_lambda.arn
}

# Lambda permission to allow CloudWatch Events to invoke the function
resource "aws_lambda_permission" "allow_cloudwatch" {
  provider      = aws.region
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_retention_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
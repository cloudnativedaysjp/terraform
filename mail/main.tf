terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3"
    }
  }
  cloud {
    organization = "cloudnativedaysjp"

    workspaces {
      name = "mail"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_ses_domain_identity" "cnd" {
  domain = "cloudnativedays.jp"
}

resource "aws_ses_receipt_rule" "default" {
  name          = "service-registration"
  rule_set_name = "cloudnativedays.jp"
  recipients    = ["twitter@cloudnativedays.jp", "support@cloudnativedays.jp"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = "cloudnativedaysjp-received-emails"
    position    = 1
  }

  lambda_action {
    function_arn    = "arn:aws:lambda:us-west-2:607167088920:function:TransterEmail"
    invocation_type = "Event"
    position        = 2
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "basic_execution_role_policy" {
  name = "AWSLambdaBasicExecutionRole-f841293c-0f53-4481-9ab7-904d80ca197a"
  path = "/service-role/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "arn:aws:logs:us-west-2:607167088920:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:us-west-2:607167088920:log-group:/aws/lambda/TransterEmail:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "iam_for_transfer_email" {
  name               = "TransterEmail-role-wj50wj4h"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path               = "/service-role/"
  managed_policy_arns = [
    aws_iam_policy.basic_execution_role_policy.arn,
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "transfer_email" {
  filename      = "lambda_function_payload.zip"
  function_name = "TransterEmail"
  role          = aws_iam_role.iam_for_transfer_email.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
  publish = true

  environment {
    variables = {
      S3_BUCKET         = var.s3_bucket_name,
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}
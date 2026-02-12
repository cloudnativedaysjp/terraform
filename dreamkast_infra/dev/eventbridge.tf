# ------------------------------------------------------------#
#  EventBridge - MediaPackage HarvestJob Failure Notification
#  us-west-2 -> ap-northeast-1 (cross-region) -> SNS -> Slack
# ------------------------------------------------------------#

locals {
  harvestjob_failure_event_pattern = jsonencode({
    source      = ["aws.mediapackagev2"]
    detail-type = ["MediaPackageV2 HarvestJob Notification"]
    detail = {
      harvestJob = {
        status = ["FAILED"]
      }
    }
  })
}

# us-west-2: EventBridge rule -> forward to Tokyo event bus

resource "aws_iam_role" "eventbridge_cross_region" {
  name = "${var.prj_prefix}-eventbridge-cross-region"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_cross_region" {
  name = "put-events-to-tokyo"
  role = aws_iam_role.eventbridge_cross_region.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "events:PutEvents"
        Resource = aws_cloudwatch_event_bus.tokyo.arn
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "harvestjob_failure" {
  name          = "${var.prj_prefix}-harvestjob-failure"
  description   = "Detects MediaPackage V2 HarvestJob failures and forwards to Tokyo"
  event_pattern = local.harvestjob_failure_event_pattern
}

resource "aws_cloudwatch_event_target" "harvestjob_failure_to_tokyo" {
  rule      = aws_cloudwatch_event_rule.harvestjob_failure.name
  target_id = "forward-to-tokyo"
  arn       = aws_cloudwatch_event_bus.tokyo.arn
  role_arn  = aws_iam_role.eventbridge_cross_region.arn
}

# ap-northeast-1: EventBridge rule -> SNS

resource "aws_cloudwatch_event_bus" "tokyo" {
  provider = aws.tokyo
  name     = "${var.prj_prefix}-harvestjob"
}

data "aws_sns_topic" "cloudnativedays_alerm" {
  provider = aws.tokyo
  name     = "cloudnativedays-alerm"
}

resource "aws_cloudwatch_event_rule" "harvestjob_failure_tokyo" {
  provider       = aws.tokyo
  name           = "${var.prj_prefix}-harvestjob-failure"
  description    = "Forwards MediaPackage HarvestJob failures to SNS"
  event_bus_name = aws_cloudwatch_event_bus.tokyo.name
  event_pattern  = local.harvestjob_failure_event_pattern
}

resource "aws_cloudwatch_event_target" "harvestjob_failure_to_sns" {
  provider       = aws.tokyo
  rule           = aws_cloudwatch_event_rule.harvestjob_failure_tokyo.name
  event_bus_name = aws_cloudwatch_event_bus.tokyo.name
  target_id      = "send-to-sns"
  arn            = data.aws_sns_topic.cloudnativedays_alerm.arn
}

# ------------------------------------------------------------#
#  EventBridge - MediaPackage HarvestJob Failure Notification
# ------------------------------------------------------------#

data "aws_sns_topic" "cloudnativedays_alerm" {
  name = "cloudnativedays-alerm"
}

resource "aws_cloudwatch_event_rule" "harvestjob_failure" {
  name        = "${var.prj_prefix}-harvestjob-failure"
  description = "Detects MediaPackage V2 HarvestJob failures"

  event_pattern = jsonencode({
    source      = ["aws.mediapackagev2"]
    detail-type = ["MediaPackageV2 HarvestJob Notification"]
    detail = {
      harvestJob = {
        status = ["FAILED"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "harvestjob_failure_to_sns" {
  rule      = aws_cloudwatch_event_rule.harvestjob_failure.name
  target_id = "send-to-sns"
  arn       = data.aws_sns_topic.cloudnativedays_alerm.arn
}

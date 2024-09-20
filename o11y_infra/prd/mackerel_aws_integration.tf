data "aws_iam_policy_document" "mackerel_aws_integration_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::217452466226:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["iUmC8uhM5dYZt9RuSikXDwGWvBlCeOZSezLBKxcr"]
    }
  }
}

data "aws_iam_policy_document" "mackerel_aws_integration_inline_policy" {
  statement {
    actions   = [
      "AWSBudgetsReadOnlyAccess",
      "AmazonEC2ReadOnlyAccess",
      "AmazonElastiCacheReadOnlyAccess",
      "AmazonRDSReadOnlyAccess",
      "AmazonSQSReadOnlyAccess",
      "CloudWatchReadOnlyAccess",
      "ecs:Describe*",
      "ecs:List*",
      "sqs:ListQueueTags"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "mackerel_aws_integration" {
  name = "mackerel-aws-integration"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.mackerel_aws_integration_assume_role_policy.json
  inline_policy {
    name   = "mackerel-aws-integration"
    policy = data.aws_iam_policy_document.mackerel_aws_integration_inline_policy.json
  }
}

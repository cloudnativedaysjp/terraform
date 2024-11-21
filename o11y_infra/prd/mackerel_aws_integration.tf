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
      values   = ["3xrDMcIWgrs862LSz72jEv93130iW7fYfto6B5iN"]
    }
  }
}

resource "aws_iam_role" "mackerel_aws_integration" {
  name = "mackerel-aws-integration-2"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.mackerel_aws_integration_assume_role_policy.json
}

# ALB インテグレーション
resource "aws_iam_role_policy_attachment" "mackerel_aws_integration_AmazonEC2ReadOnlyAccess_policy_attachment" {
  role       = aws_iam_role.mackerel_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# ElastiCache インテグレーション
resource "aws_iam_role_policy_attachment" "mackerel_aws_integration_AmazonElastiCacheReadOnlyAccess_policy_attachment" {
  role       = aws_iam_role.mackerel_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
}

# RDS インテグレーション
resource "aws_iam_role_policy_attachment" "mackerel_aws_integration_AmazonRDSReadOnlyAccess_policy_attachment" {
  role       = aws_iam_role.mackerel_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

# SQS インテグレーション
resource "aws_iam_role_policy_attachment" "mackerel_aws_integration_AmazonSQSReadOnlyAccess_policy_attachment" {
  role       = aws_iam_role.mackerel_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "mackerel_aws_integration_CloudWatchReadOnlyAccess_policy_attachment" {
  role       = aws_iam_role.mackerel_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

data "aws_iam_policy_document" "mackerel_aws_integration_inline_policy" {
  statement {
    actions   = [
      "ecs:Describe*", # ECS インテグレーション
      "ecs:List*", # ECS インテグレーション
      "elasticache:ListTagsForResource", # ElastiCache インテグレーション
      "sqs:ListQueueTags" # SQS インテグレーション
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "mackerel_aws_integration_inline_policy" {
  name        = "mackerel-aws-integration-inline-policy"
  description = "Mackerel AWS Integration Inline Policy"
  policy      = data.aws_iam_policy_document.mackerel_aws_integration_inline_policy.json
}

resource "aws_iam_policy_attachment" "mackerel_aws_integration_inline_policy_attachment" {
  name       = "mackerel-aws-integration-inline-policy-attachment"
  roles      = [aws_iam_role.mackerel_aws_integration.name]
  policy_arn = aws_iam_policy.mackerel_aws_integration_inline_policy.arn
}

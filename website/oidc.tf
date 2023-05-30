resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions.json
  description        = "IAM Role for GitHub Actions OIDC"
}

locals {
  allowed_github_repositories = [
    "website"
  ]
  github_org_name = "cloudnativedaysjp"
  full_paths = [
    for repo in local.allowed_github_repositories : "repo:${local.github_org_name}/${repo}:*"
  ]
}

data "aws_iam_openid_connect_provider" "github_actions" {
  arn = "arn:aws:iam::607167088920:oidc-provider/token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.full_paths
    }
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "cloudfront" {
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
  role       = aws_iam_role.github_actions.name
}

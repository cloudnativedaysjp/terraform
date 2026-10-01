terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  cloud {
    organization = "cloudnativedaysjp"

    workspaces {
      name = "github_actions_assume_aws_role"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}


resource "aws_iam_role" "github_actions" {
  name               = "github-actions-dreamkast"
  assume_role_policy = data.aws_iam_policy_document.github_actions.json
  description        = "IAM Role for GitHub Actions OIDC"
}

locals {
  allowed_github_repositories = [
    "dreamkast",
    "dreamkast-infra",
    "dreamkast-otelcol",
    "dreamkast-ui",
    "dreamkast-weaver",
    "seaman",
    #"website",  # website is maintained under ../website/
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

resource "aws_iam_role_policy_attachment" "ecs" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicPowerUser"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "ecr-public" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.github_actions.name
}

resource "aws_iam_role_policy_attachment" "eventbridge" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
  role       = aws_iam_role.github_actions.name
}

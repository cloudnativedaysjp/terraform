#
# Each private repositories will be pushed the following image tags.
#
# * us-west-2:
#     * pushed tags formatted commit-hash & branch-name
# * ap-northeast-1:
#     * pushed tags formatted commit-hash & semver format
#

locals {
  repositories = {
    "us-west-2" : [
      "dreamkast-ecs",
      "dreamkast-ui",
      "dreamkast-weaver",
      "dreamkast-external-scaler",
      "emtec-ecu/emtectl",
      "emtec-ecu/server",
      "seaman",
    ],
    "ap-northeast-1" : [
      "dreamkast-ecs",
      "dreamkast-ui",
      "dreamkast-weaver",
      "seaman",
    ],
  }
}

#
# us-west-2
#

resource "aws_ecr_repository" "us_west_2" {
  provider = aws
  for_each = toset(local.repositories.us-west-2)

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "us_west_2" {
  provider = aws
  for_each = toset(local.repositories.us-west-2)

  repository = aws_ecr_repository.us_west_2[each.key].name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 3 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["commit-"],
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_pull_through_cache_rule" "us_west_2" {
  provider              = aws
  ecr_repository_prefix = "ecr-public"
  upstream_registry_url = "public.ecr.aws"
}

#
# asia-northeast-1
#

resource "aws_ecr_repository" "ap_northeast_1" {
  provider = aws.ap-northeast-1
  for_each = toset(local.repositories.ap-northeast-1)

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ap_northeast_1" {
  provider = aws.ap-northeast-1
  for_each = toset(local.repositories.ap-northeast-1)

  repository = aws_ecr_repository.ap_northeast_1[each.key].name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 3 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["commit-"],
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_pull_through_cache_rule" "ap_northeast_1" {
  provider              = aws.ap-northeast-1
  ecr_repository_prefix = "ecr-public"
  upstream_registry_url = "public.ecr.aws"
}

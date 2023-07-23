#
# Private repositories are created by the following policy.
#
# * us-west-1:
#     * pushed tags formatted commit-hash
#     * following lifecycle policies
#         * against untagged image, expired 30 days after it was pushed
#         * against tagged image, no policy
#

locals {
  repositories = [
    "dreamkast-ecs",
    "dreamkast-ui",
    "dreamkast-weaver",
    "dreamkast-external-scaler",
    "emtec-ecu/emtectl",
    "emtec-ecu/server",
    "seaman",
  ]
}

resource "aws_ecr_repository" "us_west_2" {
  for_each = toset(local.repositories)

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "us_west_2" {
  for_each = toset(local.repositories)

  repository = aws_ecr_repository.us_west_2[each.key].name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "untagged",
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

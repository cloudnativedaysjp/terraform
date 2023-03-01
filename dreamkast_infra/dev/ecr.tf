resource "aws_ecr_repository" "ecr" {
  name = var.ecr_name
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
  "rules":[
    {
      "rulePriority":1,
      "description":"mainタグの制御",
      "selection":{
        "tagStatus":"tagged",
        "tagPrefixList":["main"],
        "countType":"imageCountMoreThan",
        "countNumber":2
      },
      "action":{
        "type":"expire"
      }
    },
    {
      "rulePriority":2,
      "description":"asset-compile-cacheの制御",
      "selection":{
        "tagStatus":"tagged",
        "tagPrefixList":["asset-compile-cache"],
        "countType":"imageCountMoreThan",
        "countNumber":2
      },
      "action":{
        "type":"expire"
      }
    },
    {
      "rulePriority":3,
      "description":"node-cacheの制御",
      "selection":{
        "tagStatus":"tagged",
        "tagPrefixList":["node-cache"],
        "countType":"imageCountMoreThan",
        "countNumber":2
      },
      "action":{
        "type":"expire"
      }
    },
    {
      "rulePriority":4,
      "description":"fetch-lib-cacheの制御",
      "selection":{
        "tagStatus":"tagged",
        "tagPrefixList":["fetch-lib-cache"],
        "countType":"imageCountMoreThan",
        "countNumber":2
      },
      "action":{
        "type":"expire"
      }
    }
  ]
}
EOF
}

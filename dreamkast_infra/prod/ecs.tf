resource "aws_ecs_cluster" "dreamkast_prod" {
  name = var.prj_prefix

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

data "aws_iam_policy_document" "assume_role_policy_ecs" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "task-execution-role" {
  name = "${var.prj_prefix}-ecs-task-execution-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
  ]

  inline_policy {
    name = "PullImagesViaPullThroughCache"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [
          "ecr:BatchImportUpstreamImage",
          "ecr:CreateRepository",
          "ecr:TagResource",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }]
    })
  }
  inline_policy {
    name = "CloudWatchLogsWriter"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",

        ]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:*:*:*"]
      }]
    })
  }
  inline_policy {
    name = "SecretManagerReader"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt",
        ]
        Effect   = "Allow"
        Resource = "*"
      }]
    })
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# for ECS scheduled task
resource "aws_iam_role" "ecs-scheduled-task-target-role" {
  name = "${var.prj_prefix}-ecs-scheduled-task-target-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    data.aws_iam_policy.AmazonEC2ContainerServiceEventsRole.arn
  ]
}

# ------------------------------------------------------------#
# for dreamkast
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-dreamkast" {
  name = "${var.prj_prefix}-ecs-dreamkast"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
    data.aws_iam_policy.AWSElementalMediaLiveFullAccess.arn,
    data.aws_iam_policy.AmazonS3FullAccess.arn,
    data.aws_iam_policy.AmazonSESFullAccess.arn,
    data.aws_iam_policy.AmazonSQSFullAccess.arn,
    data.aws_iam_policy.AWSElementalMediaPackageV2FullAccess.arn,
    data.aws_iam_policy.AWSElementalMediaLiveFullAccess.arn,
    data.aws_iam_policy.AWSElementalMediaPackageFullAccess.arn,
    data.aws_iam_policy.AWSElementalMediaPackageV2FullAccess.arn
  ]

  inline_policy {
    name = "IvsWriter"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ivs:CreateChannel",
            "ivs:CreateRecordingConfiguration",
            "ivs:GetChannel",
            "ivs:GetRecordingConfiguration",
            "ivs:GetStream",
            "ivs:GetStreamKey",
            "ivs:GetStreamSession",
            "ivs:ListChannels",
            "ivs:ListRecordingConfigurations",
            "ivs:ListStreamKeys",
            "ivs:ListStreams",
            "ivs:ListStreamSessions",
            "ivs:DeleteChannel",
            "ivs:TagResource"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:AttachRolePolicy",
            "iam:CreateServiceLinkedRole",
            "iam:PutRolePolicy"
          ]
          Resource = "arn:aws:iam::*:role/aws-service-role/ivs.amazonaws.com/AWSServiceRoleForIVSRecordToS3*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:GetRole",
            "iam:PassRole"
          ]
          Resource = [
            "arn:aws:iam::607167088920:role/MediaLiveAccessRole",
            "arn:aws:iam::607167088920:role/MediaPackageLivetoVOD-Policy"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "cloudfront:GetDistribution",
            "cloudfront:UpdateDistribution",
            "cloudfront:ListCachePolicies"
          ],
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "StreamingResourcePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ssm:PutParameter",
            "ssm:DeleteParameter",
            "ssm:AddTagsToResource",
            "ssm:DeleteParameters",
            "ssm:DescribeParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory",
            "ssm:GetParameters",
            "ssm:GetParametersByPath"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:GetRole",
            "iam:PassRole"
          ]
          Resource = [
            "arn:aws:iam::607167088920:role/MediaLiveAccessRole",
            "arn:aws:iam::607167088920:role/MediaPackageLivetoVOD-Policy"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "cloudfront:GetDistribution",
            "cloudfront:UpdateDistribution",
            "cloudfront:ListCachePolicies"
          ],
          Resource = "*"
        }
      ]
    })
  }
  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "ecs-dreamkast" {
  name   = "${var.prj_prefix}-ecs-dreamkast"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "tcp/3000"
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    security_groups = [
      aws_security_group.alb.id,
    ]
  }

  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
# for dreamkast-fifo-worker
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-dreamkast-fifo-worker" {
  name = "${var.prj_prefix}-ecs-dreamkast-fifo-worker"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
    data.aws_iam_policy.AmazonSESFullAccess.arn,
    data.aws_iam_policy.AmazonSQSFullAccess.arn,
    data.aws_iam_policy.AWSElementalMediaLiveFullAccess.arn,
    data.aws_iam_policy.AWSElementalMediaPackageFullAccess.arn,
  ]

  inline_policy {
    name = "StreamingResourcePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ssm:PutParameter",
            "ssm:DeleteParameter",
            "ssm:AddTagsToResource",
            "ssm:DeleteParameters",
            "ssm:DescribeParameters",
            "ssm:GetParameter",
            "ssm:GetParameterHistory",
            "ssm:GetParameters",
            "ssm:GetParametersByPath"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:GetRole",
            "iam:PassRole"
          ]
          Resource = [
            "arn:aws:iam::607167088920:role/MediaLiveAccessRole",
            "arn:aws:iam::607167088920:role/MediaPackageLivetoVOD-Policy"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "cloudfront:GetDistribution",
            "cloudfront:UpdateDistribution",
            "cloudfront:ListCachePolicies"
          ],
          Resource = "*"
        }
      ]
    })
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "ecs-dreamkast-fifo-worker" {
  name   = "${var.prj_prefix}-ecs-dreamkast-fifo-worker"
  vpc_id = module.vpc.vpc_id

  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
# for dreamkast-ui
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-dreamkast-ui" {
  name = "${var.prj_prefix}-ecs-dreamkast-ui"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
  ]

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "ecs-dreamkast-ui" {
  name   = "${var.prj_prefix}-ecs-dreamkast-ui"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "tcp/3001"
    protocol    = "tcp"
    from_port   = 3001
    to_port     = 3001
    security_groups = [
      aws_security_group.alb.id,
    ]
  }

  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
# for dreamkast-weaver
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-dreamkast-weaver" {
  name = "${var.prj_prefix}-ecs-dreamkast-weaver"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
  ]

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "ecs-dreamkast-weaver" {
  name   = "${var.prj_prefix}-ecs-dreamkast-weaver"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "tcp/8080"
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    security_groups = [
      aws_security_group.alb.id,
    ]
  }

  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
# for redis
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-redis" {
  name = "${var.prj_prefix}-ecs-redis"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
  ]

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "ecs-redis" {
  name   = "${var.prj_prefix}-ecs-redis"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "tcp/6379"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.alb.id,
      aws_security_group.ecs-dreamkast.id,
      aws_security_group.ecs-dreamkast-fifo-worker.id,
    ]
  }

  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
# for mysql
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-mysql" {
  name = "${var.prj_prefix}-ecs-mysql"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
  ]

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "ecs-mysql" {
  name   = "${var.prj_prefix}-ecs-mysql"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "tcp/3306"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.alb.id,
      aws_security_group.ecs-dreamkast.id,
      aws_security_group.ecs-dreamkast-fifo-worker.id,
      aws_security_group.ecs-dreamkast-weaver.id,
    ]
  }

  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
# for post-registration
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-post-registration" {
  name = "${var.prj_prefix}-ecs-post-registration"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
  ]

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "ecs-post-registration" {
  name   = "${var.prj_prefix}-ecs-post-registration"
  vpc_id = module.vpc.vpc_id

  ingress = []
  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_ecs_cluster" "dreamkast_dev" {
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

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "task-execution-role-ecr" {
  role       = aws_iam_role.task-execution-role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

resource "aws_iam_role_policy" "task-execution-role-pull-through-cache" {
  name = "PullImagesViaPullThroughCache"
  role = aws_iam_role.task-execution-role.id

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

resource "aws_iam_role_policy" "task-execution-role-cloudwatch-logs" {
  name = "CloudWatchLogsWriter"
  role = aws_iam_role.task-execution-role.id

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

resource "aws_iam_role_policy" "task-execution-role-secrets-manager" {
  name = "SecretManagerReader"
  role = aws_iam_role.task-execution-role.id

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
}

resource "aws_iam_role_policy_attachment" "ecs-scheduled-task-target-role-events" {
  role       = aws_iam_role.ecs-scheduled-task-target-role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceEventsRole.arn
}

# ------------------------------------------------------------#
# for dreamkast
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-dreamkast" {
  name = "${var.prj_prefix}-ecs-dreamkast"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-ssm" {
  role       = aws_iam_role.ecs-dreamkast.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-medialive" {
  role       = aws_iam_role.ecs-dreamkast.name
  policy_arn = data.aws_iam_policy.AWSElementalMediaLiveFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-s3" {
  role       = aws_iam_role.ecs-dreamkast.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-ses" {
  role       = aws_iam_role.ecs-dreamkast.name
  policy_arn = data.aws_iam_policy.AmazonSESFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-sqs" {
  role       = aws_iam_role.ecs-dreamkast.name
  policy_arn = data.aws_iam_policy.AmazonSQSFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-mediapackagev2" {
  role       = aws_iam_role.ecs-dreamkast.name
  policy_arn = data.aws_iam_policy.AWSElementalMediaPackageV2FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-mediapackage" {
  role       = aws_iam_role.ecs-dreamkast.name
  policy_arn = data.aws_iam_policy.AWSElementalMediaPackageFullAccess.arn
}

resource "aws_iam_role_policy" "ecs-dreamkast-ivs-writer" {
  name = "IvsWriter"
  role = aws_iam_role.ecs-dreamkast.id

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

resource "aws_iam_role_policy" "ecs-dreamkast-streaming-resource" {
  name = "StreamingResourcePolicy"
  role = aws_iam_role.ecs-dreamkast.id

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
    protocol    = "-1"
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

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-fifo-worker-ssm" {
  role       = aws_iam_role.ecs-dreamkast-fifo-worker.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-fifo-worker-ses" {
  role       = aws_iam_role.ecs-dreamkast-fifo-worker.name
  policy_arn = data.aws_iam_policy.AmazonSESFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-fifo-worker-sqs" {
  role       = aws_iam_role.ecs-dreamkast-fifo-worker.name
  policy_arn = data.aws_iam_policy.AmazonSQSFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-fifo-worker-medialive" {
  role       = aws_iam_role.ecs-dreamkast-fifo-worker.name
  policy_arn = data.aws_iam_policy.AWSElementalMediaLiveFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-fifo-worker-mediapackage" {
  role       = aws_iam_role.ecs-dreamkast-fifo-worker.name
  policy_arn = data.aws_iam_policy.AWSElementalMediaPackageFullAccess.arn
}

resource "aws_iam_role_policy" "ecs-dreamkast-fifo-worker-streaming-resource" {
  name = "StreamingResourcePolicy"
  role = aws_iam_role.ecs-dreamkast-fifo-worker.id

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

resource "aws_security_group" "ecs-dreamkast-fifo-worker" {
  name   = "${var.prj_prefix}-ecs-dreamkast-fifo-worker"
  vpc_id = module.vpc.vpc_id

  egress {
    description = "allow all"
    protocol    = "-1"
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

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-ui-ssm" {
  role       = aws_iam_role.ecs-dreamkast-ui.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
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
    protocol    = "-1"
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

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "ecs-dreamkast-weaver-ssm" {
  role       = aws_iam_role.ecs-dreamkast-weaver.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
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
    protocol    = "-1"
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

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "ecs-redis-ssm" {
  role       = aws_iam_role.ecs-redis.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
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
    protocol    = "-1"
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

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "ecs-mysql-ssm" {
  role       = aws_iam_role.ecs-mysql.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
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
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
# for harvestjob
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs-harvestjob" {
  name = "${var.prj_prefix}-ecs-harvestjob"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_iam_role_policy_attachment" "ecs-harvestjob-ssm" {
  role       = aws_iam_role.ecs-harvestjob.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "ecs-harvestjob-s3" {
  role       = aws_iam_role.ecs-harvestjob.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-harvestjob-mediapackage" {
  role       = aws_iam_role.ecs-harvestjob.name
  policy_arn = data.aws_iam_policy.AWSElementalMediaPackageFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "ecs-harvestjob-mediapackagev2" {
  role       = aws_iam_role.ecs-harvestjob.name
  policy_arn = data.aws_iam_policy.AWSElementalMediaPackageV2FullAccess.arn
}

resource "aws_security_group" "ecs-harvestjob" {
  name   = "${var.prj_prefix}-ecs-harvestjob"
  vpc_id = module.vpc.vpc_id

  ingress = []
  egress {
    description = "allow all"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

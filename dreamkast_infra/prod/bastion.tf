# ------------------------------------------------------------#
# for bastion (stepping stone)
# ------------------------------------------------------------#

# IAM Role for bastion task
resource "aws_iam_role" "ecs-bastion" {
  name = "${var.prj_prefix}-ecs-bastion"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs.json

  tags = {
   Environment = "${var.prj_prefix}"
  }
}

resource "aws_iam_role_policy_attachment" "ecs-bastion-ssm" {
  role       = aws_iam_role.ecs-bastion.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

# Security group for bastion
resource "aws_security_group" "ecs-bastion" {
  name   = "${var.prj_prefix}-ecs-bastion"
  vpc_id = module.vpc.vpc_id

  # Allow access to RDS from bastion
  egress {
    description     = "MySQL to RDS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_rds.id]
  }

  # Allow all outbound for general connectivity
  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
   Environment = "${var.prj_prefix}"
  }
}

# Update RDS security group to allow access from bastion
resource "aws_security_group_rule" "rds_allow_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs-bastion.id
  security_group_id        = aws_security_group.allow_rds.id
  description              = "MySQL from bastion"
}

# ECS Task Definition for bastion
resource "aws_ecs_task_definition" "bastion" {
  family                   = "${var.prj_prefix}-bastion"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-bastion.arn

  container_definitions = jsonencode([
    {
      name  = "bastion"
      image = "${var.aws_account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/bastion:latest"

      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.prj_prefix}-bastion"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }

      environment = []
    }
  ])
}

# CloudWatch Log Group for bastion
resource "aws_cloudwatch_log_group" "bastion" {
  name              = "/ecs/${var.prj_prefix}-bastion"
  retention_in_days = 7
}


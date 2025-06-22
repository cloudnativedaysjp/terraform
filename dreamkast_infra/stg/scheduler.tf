# ------------------------------------------------------------#
# EventBridge Scheduler to stop ECS services and RDS at 23:00 daily
# ------------------------------------------------------------#

# IAM role for EventBridge to stop ECS services and RDS
resource "aws_iam_role" "eventbridge_stop_ecs_role" {
  name = "${var.prj_prefix}-eventbridge-stop-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for stopping ECS services
resource "aws_iam_policy" "stop_ecs_policy" {
  name        = "${var.prj_prefix}-stop-ecs-policy"
  description = "Policy to allow stopping ECS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:ListServices",
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# IAM policy for stopping RDS instances
resource "aws_iam_policy" "stop_rds_policy" {
  name        = "${var.prj_prefix}-stop-rds-policy"
  description = "Policy to allow stopping RDS instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:StopDBInstance",
          "rds:DescribeDBInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the ECS policy to the role
resource "aws_iam_role_policy_attachment" "stop_ecs_policy_attachment" {
  role       = aws_iam_role.eventbridge_stop_ecs_role.name
  policy_arn = aws_iam_policy.stop_ecs_policy.arn
}

# Attach the RDS policy to the role
resource "aws_iam_role_policy_attachment" "stop_rds_policy_attachment" {
  role       = aws_iam_role.eventbridge_stop_ecs_role.name
  policy_arn = aws_iam_policy.stop_rds_policy.arn
}

# EventBridge scheduler to stop dreamkast service at 23:00 daily
resource "aws_scheduler_schedule" "stop_dreamkast_service" {
  name        = "${var.prj_prefix}-stop-dreamkast-service"
  description = "Stop dreamkast service in staging environment at 23:00 daily"
  
  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression = "cron(0 14 * * ? *)" # 23:00 JST (14:00 UTC)
  
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.eventbridge_stop_ecs_role.arn
    
    input = jsonencode({
      cluster        = aws_ecs_cluster.dreamkast_stg.name
      service        = "${var.prj_prefix}-dreamkast"
      desiredCount   = 0
    })
  }
}

# EventBridge scheduler to stop dreamkast-ui service at 23:00 daily
resource "aws_scheduler_schedule" "stop_dreamkast_ui_service" {
  name        = "${var.prj_prefix}-stop-dreamkast-ui-service"
  description = "Stop dreamkast-ui service in staging environment at 23:00 daily"
  
  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression = "cron(0 14 * * ? *)" # 23:00 JST (14:00 UTC)
  
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.eventbridge_stop_ecs_role.arn
    
    input = jsonencode({
      cluster        = aws_ecs_cluster.dreamkast_stg.name
      service        = "${var.prj_prefix}-dreamkast-ui"
      desiredCount   = 0
    })
  }
}

# ------------------------------------------------------------#
# EventBridge scheduler to stop RDS instance at 23:00 daily
# ------------------------------------------------------------#
resource "aws_scheduler_schedule" "stop_rds_instance" {
  name        = "${var.prj_prefix}-stop-rds-instance"
  description = "Stop RDS instance in staging environment at 23:00 daily"
  
  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression = "cron(0 14 * * ? *)" # 23:00 JST (14:00 UTC)
  
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = aws_iam_role.eventbridge_stop_ecs_role.arn
    
    input = jsonencode({
      DBInstanceIdentifier = aws_db_instance.rds_instance.identifier
    })
  }
}

# EventBridge scheduler to stop dreamkast-weaver service at 23:00 daily
resource "aws_scheduler_schedule" "stop_dreamkast_weaver_service" {
  name        = "${var.prj_prefix}-stop-dreamkast-weaver-service"
  description = "Stop dreamkast-weaver service in staging environment at 23:00 daily"
  
  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression = "cron(0 14 * * ? *)" # 23:00 JST (14:00 UTC)
  
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.eventbridge_stop_ecs_role.arn
    
    input = jsonencode({
      cluster        = aws_ecs_cluster.dreamkast_stg.name
      service        = "${var.prj_prefix}-dreamkast-weaver"
      desiredCount   = 0
    })
  }
}
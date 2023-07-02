# ------------------------------------------------------------#
#  RDS parameter group
# ------------------------------------------------------------#
resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "${var.prj_prefix}-${var.db_instance_name}-parametergroup"
  family      = "mysql${var.mysql_major_version}"
  description = "${var.prj_prefix}-${var.db_instance_name}-parm"

  # データベースに設定するパラメーター
  parameter {
    name  = "slow_query_log"
    value = 1
  }
  parameter {
    name  = "long_query_time"
    value = var.long_query_time
  }
  parameter {
    name  = "log_output"
    value = "FILE"
  }
}

# ------------------------------------------------------------#
#  RDS subnet group
# ------------------------------------------------------------#
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.prj_prefix}-${var.db_instance_name}-subnet"
  subnet_ids = data.aws_subnets.dreamkast_dev_intra.ids
}

# ------------------------------------------------------------#
#  Security group for RDS
# ------------------------------------------------------------#
resource "aws_security_group" "allow_rds" {
  name   = "${var.prj_prefix}-${var.db_instance_name}-sg"
  vpc_id = data.aws_vpc.dreamkast_dev_vpc.id

  ingress {
    description = "MySQL from private subnet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.dreamkast_dev_private : s.cidr_block]
  }
  ingress {
    description = "MySQL from public subnet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.dreamkast_dev_public : s.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prj_prefix}-${var.db_instance_name}-sg"
  }
}

# ------------------------------------------------------------#
#  RDS DB Instance
# ------------------------------------------------------------#
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
}

resource "aws_db_instance" "rds_instance" {
  engine         = "mysql"
  engine_version = "${var.mysql_major_version}.${var.mysql_minor_version}"

  identifier = "${var.prj_prefix}-${var.db_instance_name}"
  db_name    = var.db_name
  username   = var.db_user_name
  password   = random_password.rds_password.result

  instance_class    = var.db_instance_class
  allocated_storage = var.db_instance_storage_size
  storage_type      = var.db_instance_storage_type

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.allow_rds.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  parameter_group_name = aws_db_parameter_group.rds_parameter_group.name

  backup_window              = "18:00-18:30"
  maintenance_window         = "Sat:19:00-Sat:19:30"
  backup_retention_period    = 7
  auto_minor_version_upgrade = false
  copy_tags_to_snapshot      = true
  skip_final_snapshot        = true

  tags = { Name = "${var.db_instance_name}" }
}

# ------------------------------------------------------------#
#  RDS Secret
# ------------------------------------------------------------#

resource "aws_secretsmanager_secret" "rds-secret" {
  name        = "${var.prj_prefix}-rds-secret"
  description = "This is a Secrets Manager secret for an RDS DB instance"
}

resource "aws_secretsmanager_secret_version" "db-pass-val" {
  secret_id = aws_secretsmanager_secret.rds-secret.id
  # encode in the required format
  secret_string = jsonencode(
    {
      username = aws_db_instance.rds_instance.username
      password = aws_db_instance.rds_instance.password
    }
  )
}

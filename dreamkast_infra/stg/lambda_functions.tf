module "log_retention_lambda_us_east_1" {
  source = "../modules/log_retention_lambda_function"

  aws_region = "us-east-1"
}

module "log_retention_lambda_us_east_2" {
  source = "../modules/log_retention_lambda_function"

  aws_region = "us-east-2"
}

module "log_retention_lambda_us_west_1" {
  source = "../modules/log_retention_lambda_function"

  aws_region = "us-west-1"
}

module "log_retention_lambda_us_west_2" {
  source = "../modules/log_retention_lambda_function"

  aws_region = "us-west-2"
}

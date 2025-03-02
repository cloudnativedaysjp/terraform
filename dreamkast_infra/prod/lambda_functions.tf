module "log_retention_lambda_ap_northeast_1" {
  source = "../modules/log_retention_lambda_function"

  aws_region = "ap-northeast-1"
}

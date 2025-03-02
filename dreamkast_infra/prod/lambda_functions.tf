module "log_retention_lambda" {
  source = "./modules/lambda"

  aws_region = "ap-northeast-1"
}

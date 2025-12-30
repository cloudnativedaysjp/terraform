module "tfaction_aws" {
  source = "github.com/suzuki-shunsuke/terraform-aws-tfaction"

  name                             = "dreamkast"
  repo                             = "cloudnativedaysjp/terraform"
  main_branch                      = "main"
  s3_bucket_terraform_state_name   = "dreamkast-terraform-states"
  s3_bucket_tfmigrate_history_name = "dreamkast-terraform-tfmigrate-history"
}

resource "aws_iam_role_policy_attachment" "terraform_apply" {
  role       = module.tfaction_aws.aws_iam_role_terraform_apply_name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_plan" {
  role       = module.tfaction_aws.aws_iam_role_terraform_plan_name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

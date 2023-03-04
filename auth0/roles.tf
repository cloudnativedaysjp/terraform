locals {
  roles = [
    "CICD2021-Admin",
    "CICD2023-Admin",
    "CNDO2021-Admin",
    "CNDO2021-Speakers",
    "CNDT2020-Admin",
    "CNDT2020-Speakers",
    "CNDT2021-Admin",
    "CNDT2021-Speakers",
    "CNDT2022-Admin",
    "CNSEC2022-Admin",
    "CODT2021-Admin",
    "CODT2022-Admin",
    "O11Y2022-Admin",
    "O11Y2022-Speakers",
  ]
}

resource "auth0_role" "roles" {
  for_each    = { for i in local.roles : i => i }
  name        = each.value
  description = each.value
}
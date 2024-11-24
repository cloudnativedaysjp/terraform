locals {
  roles = [
    "CICD2023-Admin",
    "CODT2022-Admin",
    "O11Y2022-Admin",
    "O11Y2022-Speakers",
    "CNDF2023-Admin",
    "CNDT2023-Admin",
    "CNDS2024-Admin",
    "CNDW2024-Admin",
  ]
}

resource "auth0_role" "roles" {
  for_each    = { for i in local.roles : i => i }
  name        = each.value
  description = each.value
}

import {
  to = auth0_role.roles["CNDW2024-Admin"]
  id = "rol_UBJHrG1NLdcOkpPG"
}

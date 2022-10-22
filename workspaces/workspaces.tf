data "tfe_organization" "org" {
  name = "cloudnativedaysjp"
}

resource "tfe_team" "cloudnativedays" {
  name         = "cloudnativedays"
  organization = data.tfe_organization.org.name
}

variable "oauth_token_id" {
  default = "ot-25zDMn4WC9dFQ2mX"
}

resource "tfe_organization_membership" "members" {
  for_each = toset(var.members)
  organization  = data.tfe_organization.org.name
  email = each.value
}

resource "tfe_team_organization_member" "members" {
  for_each = tfe_organization_membership.members
  team_id   = tfe_team.cloudnativedays.id
  organization_membership_id  = each.value.id
}

resource "tfe_workspace" "workspaces" {
  name                = "workspaces"
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = true
  working_directory   = "workspaces"
  execution_mode = "remote"
  vcs_repo {
    identifier         = "cloudnativedaysjp/terraform"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_team_access" "workspaces" {
  access       = "admin"
  team_id      = tfe_team.cloudnativedays.id
  workspace_id = tfe_workspace.workspaces.id
}

locals {
  ws = [
    "sakuracloud",
    "github",
    "uptime_robot",
    "broadcast_switcher",
  ]
}
resource "tfe_workspace" "ws" {
  for_each = toset(local.ws)
  name                = each.value
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = true
  working_directory   = each.value
  execution_mode = "remote"
  trigger_patterns = each.value
  vcs_repo {
    identifier         = "cloudnativedaysjp/terraform"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_team_access" "ws" {
  for_each = toset(local.ws)
  access       = "admin"
  team_id      = tfe_team.cloudnativedays.id
  workspace_id = tfe_workspace.ws[each.value].id
}

moved {
  from = tfe_workspace.sakuracloud
  to = tfe_workspace.ws["sakuracloud"]
}

moved {
  from = tfe_team_access.sakuracloud
  to = tfe_team_access.ws["sakuracloud"]
}

moved {
  from = tfe_workspace.github
  to = tfe_workspace.ws["github"]
}

moved {
  from = tfe_team_access.github
  to = tfe_team_access.ws["github"]
}



moved {
  from = tfe_workspace.broadcast_switcher
  to = tfe_workspace.ws["broadcast_switcher"]
}

moved {
  from = tfe_team_access.broadcast_switcher
  to = tfe_team_access.ws["broadcast_switcher"]
}



moved {
  from = tfe_workspace.uptime_robot
  to = tfe_workspace.ws["uptime_robot"]
}

moved {
  from = tfe_team_access.uptime_robot
  to = tfe_team_access.ws["uptime_robot"]
}

variable "members" {
  default = []
}

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
  for_each     = toset(var.members)
  organization = data.tfe_organization.org.name
  email        = each.value
}

resource "tfe_team_organization_member" "members" {
  for_each                   = tfe_organization_membership.members
  team_id                    = tfe_team.cloudnativedays.id
  organization_membership_id = each.value.id
}

resource "tfe_workspace" "workspaces" {
  name                = "workspaces"
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = true
  working_directory   = "workspaces"
  execution_mode      = "remote"
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
    "github_actions_assume_aws_role",
  ]
}
resource "tfe_workspace" "ws" {
  for_each            = toset(local.ws)
  name                = each.value
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = true
  working_directory   = each.value
  execution_mode      = "remote"
  trigger_prefixes    = [each.value]
  vcs_repo {
    identifier         = "cloudnativedaysjp/terraform"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_notification_configuration" "ws" {
  for_each         = toset(local.ws)
  name             = each.value
  enabled          = true
  destination_type = "slack"
  triggers         = ["run:created", "run:planning", "run:errored"]
  url              = var.slack_url
  workspace_id     = tfe_workspace.ws[each.value].id
}

resource "tfe_team_access" "ws" {
  for_each     = toset(local.ws)
  access       = "admin"
  team_id      = tfe_team.cloudnativedays.id
  workspace_id = tfe_workspace.ws[each.value].id
}


variable "members" {
  default = []
}

variable "slack_url" {
  default = ""
}

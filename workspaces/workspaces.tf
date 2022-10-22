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

resource "tfe_workspace" "sakuracloud" {
  name                = "sakuracloud"
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = false
  working_directory   = "sakuracloud"
  execution_mode = "remote"
  vcs_repo {
    identifier         = "cloudnativedaysjp/terraform"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_team_access" "sakuracloud" {
  access       = "admin"
  team_id      = tfe_team.cloudnativedays.id
  workspace_id = tfe_workspace.sakuracloud.id
}

resource "tfe_workspace" "github" {
  name                = "github"
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = false
  working_directory   = "github"
  execution_mode = "remote"
  vcs_repo {
    identifier         = "cloudnativedaysjp/terraform"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_team_access" "github" {
  access       = "admin"
  team_id      = tfe_team.cloudnativedays.id
  workspace_id = tfe_workspace.github.id
}

resource "tfe_workspace" "uptime_robot" {
  name                = "uptime_robot"
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = false
  working_directory   = "uptime_robot"
  execution_mode = "remote"
  vcs_repo {
    identifier         = "cloudnativedaysjp/terraform"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_team_access" "uptime_robot" {
  access       = "admin"
  team_id      = tfe_team.cloudnativedays.id
  workspace_id = tfe_workspace.uptime_robot.id
}

resource "tfe_workspace" "broadcast_switcher" {
  name                = "broadcast_switcher"
  organization        = data.tfe_organization.org.name
  auto_apply          = false
  queue_all_runs      = false
  speculative_enabled = false
  working_directory   = "broadcast-switcher"
  execution_mode = "remote"
  vcs_repo {
    identifier         = "cloudnativedaysjp/terraform"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_team_access" "broadcast_switcher" {
  access       = "admin"
  team_id      = tfe_team.cloudnativedays.id
  workspace_id = tfe_workspace.broadcast_switcher.id
}

variable "members" {
  default = []
}

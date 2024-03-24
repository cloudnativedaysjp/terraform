data "local_file" "add_role_to_id_token_handler" {
  filename = "actions/addRoleToIdToken.js"
}

resource "auth0_action" "add_role_to_id_token" {
  name = "add-role-to-id-token"
  runtime = "node18"
  code = data.local_file.add_role_to_id_token_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "add_userinfo_claim_handler" {
  filename = "actions/addUserInfoClaim.js"
}

resource "auth0_action" "add_userinfo_claim" {
  name = "add-userinfo-claim"
  runtime = "node18"
  code = data.local_file.add_userinfo_claim_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "argocd_group_claim_handler" {
  filename = "actions/argocdGroupClaim.js"
}

resource "auth0_action" "argocd_group_claim" {
  name = "argocd-group-claim"
  runtime = "node18"
  code = data.local_file.argocd_group_claim_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "assign_role_aws_handler" {
  filename = "actions/assignRoleAWS.js"
}

resource "auth0_action" "assign_role_aws" {
  name = "assign-role-aws"
  runtime = "node18"
  code = data.local_file.assign_role_aws_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "auth0_account_link_extension_handler" {
  filename = "actions/auth0AccountLinkExtension.js"
}

resource "auth0_action" "auth0_account_link_extension" {
  name = "auth0-account-link-extension"
  runtime = "node18"
  code = data.local_file.auth0_account_link_extension_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "auth0_authorization_extension_handler" {
  filename = "actions/auth0AuthorizationExtension.js"
}

resource "auth0_action" "auth0_authorization_extension" {
  name = "auth0-authorization-extension"
  runtime = "node18"
  code = data.local_file.auth0_authorization_extension_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "saml_attributes_mapping_handler" {
  filename = "actions/samlAttributesMapping.js"
}

resource "auth0_action" "saml_attributes_mapping" {
  name = "saml-attributes-mapping"
  runtime = "node18"
  code = data.local_file.saml_attributes_mapping_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "whitelist_for_nextcloud_handler" {
  filename = "actions/whitelistForNextcloud.js"
}

resource "auth0_action" "whitelist_for_nextcloud" {
  name = "whitelist-for-nextcloud"
  runtime = "node18"
  code = data.local_file.whitelist_for_nextcloud_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

resource "auth0_trigger_actions" "login_flow" {
  trigger = "post-login"

  // NOTE: Auth0 Actions will be executed in the order they are listed here
  dynamic "actions" {
    for_each = [
      auth0_action.add_role_to_id_token,
      auth0_action.add_userinfo_claim,
      auth0_action.auth0_account_link_extension,
      auth0_action.auth0_authorization_extension,
      auth0_action.argocd_group_claim,
      auth0_action.saml_attributes_mapping,
      auth0_action.whitelist_for_nextcloud,
      auth0_action.assign_role_aws,
    ]

    content {
      id = actions.value.id
      display_name = actions.value.name
    }
  }
}

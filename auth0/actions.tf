data "local_file" "add_role_to_id_token_handler" {
  filename = "actions/addRoleToIdToken.js"
}

resource "auth0_action" "add_role_to_id_token" {
  name    = "add-role-to-id-token"
  runtime = "node18"
  deploy = true
  code    = data.local_file.add_role_to_id_token_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "add_userinfo_claim_handler" {
  filename = "actions/addUserInfoClaim.js"
}

resource "auth0_action" "add_userinfo_claim" {
  name    = "add-userinfo-claim"
  runtime = "node18"
  deploy = true
  code    = data.local_file.add_userinfo_claim_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

data "local_file" "auth0_account_link_extension_handler" {
  filename = "actions/auth0AccountLinkExtension.js"
}

resource "auth0_action" "auth0_account_link_extension" {
  name    = "auth0-account-link-extension"
  runtime = "node18"
  deploy = true
  code    = data.local_file.auth0_account_link_extension_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  # ref: https://github.com/auth0-extensions/auth0-account-link-extension/issues/165#issuecomment-1753005657
  dependencies {
    name    = "request"
    version = "2.56.0"
  }
  dependencies {
    name    = "axios"
    version = "1.5.1"
  }
  dependencies {
    name    = "querystring"
    version = "0.2.1"
  }
  dependencies {
    name    = "native-or-bluebird"
    version = "1.2.0"
  }
  dependencies {
    name    = "jsonwebtoken"
    version = "7.1.9"
  }

  # "APP_CLIENT_ID": "The ID of web app making the link between the user identities in the end",
  # "APP_CLIENT_SECRET": "The SECRET of web app making the link between the user identities in the end",
  # "AUTH0_DOMAIN": "dev-xxxxxx.us" or something similar, without leading https:// and without trailing .com
  # "BASE_URL": "https://dev-xxxxxx.us.auth0.com/api/v2",
  # "M2M_CLIENT_ID": "The ID of auth0-account-link app",
  # "M2M_CLIENT_SECRET": "The SECRET of auth0-account-link app"
  secrets {
    # Use terraform client since the client must have the permission to update user_metadata
    name  = "APP_CLIENT_ID"
    value = data.auth0_client.terraform.client_id
  }
  secrets {
    name  = "APP_CLIENT_SECRET"
    value = data.auth0_client.terraform.client_secret
  }
  secrets {
    name  = "AUTH0_DOMAIN"
    value = "dreamkast.us"
  }
  secrets {
    name  = "BASE_URL"
    value = "https://dreamkast.us.auth0.com/api/v2"
  }
  secrets {
    name  = "M2M_CLIENT_ID"
    value = data.auth0_client.auth0_account_link.client_id
  }
  secrets {
    name  = "M2M_CLIENT_SECRET"
    value = data.auth0_client.auth0_account_link.client_secret
  }

}

data "local_file" "auth0_authorization_extension_handler" {
  filename = "actions/auth0AuthorizationExtension.js"
}

resource "auth0_action" "auth0_authorization_extension" {
  name    = "auth0-authorization-extension"
  runtime = "node18"
  deploy = true
  code    = data.local_file.auth0_authorization_extension_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  dependencies {
    name    = "axios"
    version = "1.5.1"
  }

  secrets {
    name  = "AUTHZ_EXT_API_KEY"
    value = var.authz_ext_api_key
  }
}

# NOTE: This Action migrated from old Auth0 Rule but it's currently not used
# data "local_file" "saml_attributes_mapping_handler" {
#   filename = "actions/samlAttributesMapping.js"
# }

# resource "auth0_action" "saml_attributes_mapping" {
#   name = "saml-attributes-mapping"
#   runtime = "node18"
#   code = data.local_file.saml_attributes_mapping_handler.content

#   supported_triggers {
#     id      = "post-login"
#     version = "v3"
#   }
# }

data "local_file" "whitelist_for_nextcloud_handler" {
  filename = "actions/whitelistForNextcloud.js"
}

resource "auth0_action" "whitelist_for_nextcloud" {
  name    = "whitelist-for-nextcloud"
  runtime = "node18"
  deploy = true
  code    = data.local_file.whitelist_for_nextcloud_handler.content

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

# resource "auth0_trigger_actions" "login_flow" {
#   trigger = "post-login"

#   // NOTE: Auth0 Actions will be executed in the order they are listed here
#   dynamic "actions" {
#     for_each = [
#       auth0_action.add_role_to_id_token,
#       auth0_action.add_userinfo_claim,
#       auth0_action.auth0_account_link_extension,
#       auth0_action.auth0_authorization_extension,
#       auth0_action.whitelist_for_nextcloud,
#     ]

#     content {
#       id           = actions.value.id
#       display_name = actions.value.name
#     }
#   }
# }

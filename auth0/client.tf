resource "auth0_client" "tfer--0cWWdpGt4CpWjHJ9QIHtPm5GrJLS25lz_Dreamkast-0020-UI-0020---0020-Review" {
  allowed_logout_urls = ["http://localhost:8080", "https://*.dev.cloudnativedays.jp"]
  app_type            = "spa"
  callbacks = [
    "http://*.dev.cloudnativedays.jp/cicd2023/ui",
    "http://*.dev.cloudnativedays.jp/cndt2022/ui",
    "http://localhost:3001/discussionboard",
    "http://localhost:3001/cndf2023/ui",
    "https://*.dev.cloudnativedays.jp/cicd2023/ui",
    "https://*.dev.cloudnativedays.jp/cndt2022/ui",
  ]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  logo_uri = "https://dreamkast-public-bucket.s3-ap-northeast-1.amazonaws.com/Trademark.png"
  name     = "Dreamkast UI - Review"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "false"
    leeway                       = "0"
    rotation_type                = "rotating"
    token_lifetime               = "2592000"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "none"
  web_origins                = ["http://*.dev.cloudnativedays.jp", "http://localhost:3001", "http://localhost:8080", "https://*.dev.cloudnativedays.jp"]
}

resource "auth0_client" "tfer--1LoSlZw97vvX7iG3XpxtdqQfTqIDjzwk_Cloud-0020-Native-0020-Days-0020---0020-Staging" {
  allowed_logout_urls                 = ["https://*.herokuapp.com/", "https://staging.dev.cloudnativedays.jp/"]
  app_type                            = "regular_web"
  callbacks                           = ["https://*.herokuapp.com/auth/auth0/callback", "https://staging.dev.cloudnativedays.jp/auth/auth0/callback"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  logo_uri = "https://dreamkast-public-bucket.s3-ap-northeast-1.amazonaws.com/Trademark.png"
  name     = "Cloud Native Days - Staging"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "2592000"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--1tWhmO95Q3vTuR94mnhhHrqvD4TwcFao_Sentry" {


  app_type                            = "sentry"
  callbacks                           = ["https://sentry.cloudnativedays.jp/saml/acs/cloudnative-days/"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "Sentry"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "2592000"
  }

  sso          = "false"
  sso_disabled = "false"
}

resource "auth0_client" "tfer--34CNIWysaolYGdA5FK2OVGRgcNaEWNoU_ArgoCD" {
  allowed_logout_urls                 = ["https://argocd.cloudnativedays.jp/", "https://argocd.dev.cloudnativedays.jp/", "https://argocd.event.cloudopsdays.com/"]
  app_type                            = "regular_web"
  callbacks                           = ["https://argocd.cloudnativedays.jp/auth/callback", "https://argocd.dev.cloudnativedays.jp/auth/callback", "https://argocd.event.cloudopsdays.com/auth/callback"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name = "ArgoCD"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--61c91hIk6j8dz2RAaNytOyHFgyKqilTX_Grafana" {
  app_type                            = "regular_web"
  callbacks                           = ["https://grafana.cloudnativedays.jp/login/generic_oauth", "https://grafana.dev.cloudnativedays.jp/login/generic_oauth", "https://grafana.event.cloudopsdays.com/login/generic_oauth"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name = "Grafana"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--7pdRWuf14dBBu4PiEqOSY6vALFuEKCju_auth0-authz" {
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "auth0-authz"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--9xGK1rAjX2ixlWVWhE0Ycva14B6PQhiH_auth0-account-link" {
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "auth0-account-link"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "2592000"
  }

  sso          = "false"
  sso_disabled = "false"
}

resource "auth0_client" "tfer--IJsMei2A93dLHsEXDJgH75xxUIJu2jeJ_API-0020-Explorer-0020-Application" {
  app_type                            = "non_interactive"
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["client_credentials"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "API Explorer Application"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--Ivee5RoyvPB8PcUdiLZqPnGZSmixkK5N_Nextcloud" {
  addons {
    samlp {
      binding                       = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
      create_upn_claim              = "false"
      include_attribute_name_format = "false"
      lifetime_in_seconds           = "0"

      logout = {
        callback = "https://dreamkast.us.auth0.com/v2/logout?returnTo=https%3A%2F%2Fnextcloud2.cloudnativedays.jp%2Fredirect.html"
      }

      map_identities                     = "false"
      map_unknown_claims_as_is           = "false"
      passthrough_claims_with_no_mapping = "false"
      sign_response                      = "false"
      typed_attributes                   = "false"
    }
  }

  allowed_logout_urls                 = ["https://nextcloud.cloudnativedays.jp/*", "https://nextcloud.cloudnativedays.jp/redirect.html", "https://nextcloud2.cloudnativedays.jp/*", "https://nextcloud2.cloudnativedays.jp/redirect.html", "https://uploader.cloudnativedays.jp/*", "https://uploader.cloudnativedays.jp/redirect.html"]
  app_type                            = "spa"
  callbacks                           = ["https://nextcloud.cloudnativedays.jp/apps/user_saml/saml/acs", "https://nextcloud.cloudnativedays.jp/index.php/apps/user_saml/saml/acs", "https://nextcloud2.cloudnativedays.jp/apps/user_saml/saml/acs", "https://nextcloud2.cloudnativedays.jp/index.php/apps/user_saml/saml/acs", "https://uploader.cloudnativedays.jp/apps/user_saml/saml/acs", "https://uploader.cloudnativedays.jp/index.php/apps/user_saml/saml/acs"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name = "Nextcloud"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "false"
    infinite_token_lifetime      = "false"
    leeway                       = "0"
    rotation_type                = "rotating"
    token_lifetime               = "2592000"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "none"
}

resource "auth0_client" "tfer--JxqrUDloZhPPWKflAQXlmPJgxrI1d5ms_Dreamkast-0020-UI" {
  allowed_logout_urls = ["https://event.cloudnativedays.jp"]
  app_type            = "spa"
  callbacks = [
    "https://event.cloudnativedays.jp/cicd2023/ui",
    "https://event.cloudnativedays.jp/cndf2023/ui",
    "https://event.cloudnativedays.jp/cndt2022/ui",
    "https://event.cloudnativedays.jp/cnsec2022/ui",
  ]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  logo_uri = "https://dreamkast-public-bucket.s3-ap-northeast-1.amazonaws.com/Trademark.png"
  name     = "Dreamkast UI"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "false"
    infinite_token_lifetime      = "false"
    leeway                       = "0"
    rotation_type                = "rotating"
    token_lifetime               = "2592000"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "none"
  web_origins                = ["https://event.cloudnativedays.jp"]
}

resource "auth0_client" "tfer--OdhY7pRnr51ll6qdpwYS7Iv5u5LeeGlP_ReadOnlyAPI-0028-for-0020-Terraform-0020-import-0029-" {
  app_type                            = "non_interactive"
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["client_credentials"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "ReadOnlyAPI(for Terraform import)"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--Piz0aBnXn0vxesyZScc76PgdCB7lCAbk_Dreamkast-0020-API" {
  app_type                            = "non_interactive"
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["client_credentials"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name = "Dreamkast API"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--QnXQCFIndJASnVUy7dO8RAd9neGeFnP6_Dreamkast-0020-API-0020-Gateway-0020-DEV-0020--0028-Test-0020-Application-0029-" {
  app_type                            = "non_interactive"
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["client_credentials"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "Dreamkast API Gateway DEV (Test Application)"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--TPeiKSZzmH2JZJPybE290kypTUrWClTk_Dreamkast-0020-UI-0020---0020-Staging" {
  allowed_logout_urls = ["https://staging.dev.cloudnativedays.jp"]
  app_type            = "spa"
  callbacks = [
    "https://staging.dev.cloudnativedays.jp/cicd2023/ui",
    "https://staging.dev.cloudnativedays.jp/cndf2023/ui",
    "https://staging.dev.cloudnativedays.jp/cndt2022/ui",
    "https://staging.dev.cloudnativedays.jp/cnsec2022/ui",
  ]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  logo_uri = "https://dreamkast-public-bucket.s3-ap-northeast-1.amazonaws.com/Trademark.png"
  name     = "Dreamkast UI - Staging"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "false"
    leeway                       = "0"
    rotation_type                = "rotating"
    token_lifetime               = "2592000"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "none"
  web_origins                = ["http://localhost:3001/cndf2023/ui", "https://staging.dev.cloudnativedays.jp"]
}

resource "auth0_client" "tfer--VcE2MiC04c9ofKhRf3jplPFFtUyyznaX_All-0020-Applications" {
  cross_origin_auth                   = "false"
  custom_login_page_on                = "false"
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"
  name                                = "All Applications"
  oidc_conformant                     = "false"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "0"
    infinite_idle_token_lifetime = "false"
    infinite_token_lifetime      = "false"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "0"
  }

  sso          = "false"
  sso_disabled = "false"
}

resource "auth0_client" "tfer--WF6mejuYuwqeb8cMVeX0bHmpYAFzHLSn_Terraform" {
  app_type                            = "non_interactive"
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["client_credentials"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "Terraform"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--bhilCDirdMDRjXCpbRBIKdK9fdmKArI0_Cloud-0020-Native-0020-Days" {
  allowed_logout_urls                 = ["http://event.cloudnativedays.jp/", "https://event.cloudnativedays.jp/"]
  app_type                            = "regular_web"
  callbacks                           = ["http://event.cloudnativedays.jp/auth/auth0/callback", "https://event.cloudnativedays.jp/auth/auth0/callback"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  logo_uri = "https://dreamkast-public-bucket.s3-ap-northeast-1.amazonaws.com/Trademark.png"
  name     = "Cloud Native Days"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "2592000"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--bqg8diqDm14YYRIyYKHYhlEMuFhD48yd_Default-0020-App" {
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name            = "Default App"
  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "2592000"
  }

  sso          = "false"
  sso_disabled = "false"
}

resource "auth0_client" "tfer--lIrIGrhacjYsZcqEXeauzTmkK5Sz79nL_Cloud-0020-Native-0020-Days-0020---0020--0020-Review" {
  allowed_logout_urls                 = ["http://*.dev.cloudnativedays.jp/", "http://127.0.0.1:3000/", "http://127.0.0.2:3000/", "http://localhost:3000/", "http://localhost:8080/", "https://*.dev.cloudnativedays.jp/", "https://*.herokuapp.com/", "https://cloudopsdays.com/"]
  app_type                            = "regular_web"
  callbacks                           = ["http://*.dev.cloudnativedays.jp/auth/auth0/callback", "http://127.0.0.1:3000/auth/auth0/callback", "http://127.0.0.2:3000/auth/auth0/callback", "http://localhost:3000/auth/auth0/callback", "http://localhost:8080/auth/auth0/callback", "http://localhost:8080/cnsec2022/ui", "https://*.dev.cloudnativedays.jp/auth/auth0/callback", "https://*.herokuapp.com/auth/auth0/callback", "https://dreamkast.us.webtask.run/auth0-authentication-api-debugger", "https://oidcdebugger.com/debug"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  logo_uri = "https://dreamkast-public-bucket.s3-ap-northeast-1.amazonaws.com/Trademark.png"
  name     = "Cloud Native Days -  Review"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "1296000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "2592000"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
  web_origins                = ["http://*.dev.cloudnativedays.jp", "http://localhost:8080", "https://*.dev.cloudnativedays.jp"]
}

resource "auth0_client" "tfer--ukWrVdyicKKWW7UGqEUQinA2X24Ogxd1_AWS" {
  addons {
    samlp {
      audience                      = "https://ap-northeast-1.signin.aws.amazon.com/platform/saml/d-9567071dd1"
      create_upn_claim              = "false"
      destination                   = "https://ap-northeast-1.signin.aws.amazon.com/platform/saml/acs/87ecb76d-8c10-4b30-a6c6-09d0a0e2ba5b"
      include_attribute_name_format = "false"
      lifetime_in_seconds           = "0"
      map_identities                = "false"
      map_unknown_claims_as_is      = "false"

      mappings = {
        email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      }

      name_identifier_format             = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
      name_identifier_probes             = ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"]
      passthrough_claims_with_no_mapping = "false"
      sign_response                      = "false"
      typed_attributes                   = "false"
    }
  }

  app_type                            = "regular_web"
  callbacks                           = ["https://ap-northeast-1.signin.aws.amazon.com/platform/saml/acs/87ecb76d-8c10-4b30-a6c6-09d0a0e2ba5b", "https://ap-northeast-1.signin.aws.amazon.com/platform/saml/d-9567071dd1", "https://d-9567071dd1.awsapps.com/start"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name = "AWS"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

resource "auth0_client" "tfer--y94p2dhTrVM8RszZ73kqR64jvy9uJDhO_kibana" {
  allowed_logout_urls                 = ["http://localhost/", "http://localhost/validate", "https://elk.cloudnativedays.jp/", "https://elk.cloudnativedays.jp/validate"]
  app_type                            = "regular_web"
  callbacks                           = ["http://localhost/auth", "https://elk.cloudnativedays.jp/auth"]
  cross_origin_auth                   = "false"
  custom_login_page_on                = "true"
  grant_types                         = ["authorization_code", "client_credentials", "implicit", "refresh_token"]
  is_first_party                      = "true"
  is_token_endpoint_ip_header_trusted = "false"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = "36000"
    secret_encoded      = "false"
  }

  name = "kibana"

  native_social_login {
    apple {
      enabled = "false"
    }

    facebook {
      enabled = "false"
    }
  }

  oidc_conformant = "true"

  refresh_token {
    expiration_type              = "non-expiring"
    idle_token_lifetime          = "2592000"
    infinite_idle_token_lifetime = "true"
    infinite_token_lifetime      = "true"
    leeway                       = "0"
    rotation_type                = "non-rotating"
    token_lifetime               = "31557600"
  }

  sso                        = "false"
  sso_disabled               = "false"
  token_endpoint_auth_method = "client_secret_post"
}

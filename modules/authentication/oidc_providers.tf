locals {
  # Add OIDC provider names here.
  # These will be the organisation names users login on the frontend
  # when logging in using OIDC providers
  oidc_providers = [
  ]
}

resource "aws_cognito_identity_provider" "oidc" {
  count         = length(local.oidc_providers)
  provider_name = local.oidc_providers[count.index]
  provider_type = "OIDC"
  user_pool_id  = aws_cognito_user_pool.default.id

  provider_details = {
    authorize_scopes          = "email openid profile"
    client_id                 = "CHANGEMEINCONSOLE"
    client_secret             = "CHANGEMEINCONSOLE"
    oidc_issuer               = "https://changemeinconsole.com"
    authorize_url             = "https://changemeinconsole.com"
    token_url                 = "https://changemeinconsole.com"
    attributes_url            = "https://changemeinconsole.com"
    jwks_uri                  = "https://changemeinconsole.com"
    attributes_request_method = "GET"
  }

  attribute_mapping = {
    email       = "email"
    username    = "sub"
    given_name  = "given_name"
    family_name = "family_name"
  }

  lifecycle {
    ignore_changes = [
      provider_details,
      attribute_mapping,
    ]
  }
}

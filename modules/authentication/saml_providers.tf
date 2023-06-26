locals {
  # Add SAML provider names here.
  # These will be the organisation names users login on the frontend
  # when logging in using SAML providers
  saml_providers = {
    "sgn-staging" = {
      MetadataFile = file("${path.module}/metadata/sgn-staging.xml")
    },
    "sgn-production" = {
      MetadataFile = file("${path.module}/metadata/sgn-production.xml")
    },
    "fyld-staging" = {
      MetadataURL = "https://dev-732249.okta.com/app/exk5it0g0kaTsSFdi4x6/sso/saml/metadata"
    }
  }
}

resource "aws_cognito_identity_provider" "saml" {
  for_each      = local.saml_providers
  provider_name = each.key
  provider_type = "SAML"
  user_pool_id  = aws_cognito_user_pool.default.id

  provider_details = each.value

  attribute_mapping = {
    email       = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    given_name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
    family_name = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
  }

  lifecycle {
    ignore_changes = [
      provider_details,
      attribute_mapping,
    ]
  }
}

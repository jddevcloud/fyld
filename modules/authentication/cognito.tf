locals {
  base_url = var.env == "production" ? "https://www.sitestream.app" : "https://www.${var.env}.sitestream.app"
}

resource "aws_cognito_user_pool" "_" {
  name = "${var.project_name}-${var.env}-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  password_policy {
    minimum_length                   = 8
    require_numbers                  = true
    require_uppercase                = true
    require_symbols                  = true
    temporary_password_validity_days = 90
  }

  verification_message_template {
    email_message = templatefile("${path.module}/email-templates/password-reset.html", { base_url = local.base_url})
  }

  email_verification_subject = "Reset your FYLD password"

  admin_create_user_config {
    invite_message_template {
      email_message = templatefile("${path.module}/email-templates/setup-user.html", { base_url = local.base_url})
      email_subject = "Setting up your FYLD account"
      sms_message   = "Your username is {username} and temporary password is {####}"
    }
  }

  lifecycle {
    ignore_changes = [
      schema,
    ]
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "_" {
  name = "${var.project_name}-${var.env}-app-client"

  user_pool_id = aws_cognito_user_pool._.id

  generate_secret = false

  explicit_auth_flows = ["USER_PASSWORD_AUTH"]
}

resource "aws_cognito_identity_pool" "_" {
  identity_pool_name = "${var.project_name} ${var.env} identity pool"

  allow_unauthenticated_identities = false

  # Old
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client._.id
    provider_name           = aws_cognito_user_pool._.endpoint
    server_side_token_check = true
  }

  # New
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.default.id
    provider_name           = aws_cognito_user_pool.default.endpoint
    server_side_token_check = true
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "_" {
  identity_pool_id = aws_cognito_identity_pool._.id

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
  }
}

resource "aws_cognito_user_pool" "default" {
  name = "${var.project_name}-${var.env}-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "userType"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                     = "orgUuid"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "authChallenge"
    attribute_data_type      = "String"
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  password_policy {
    minimum_length                   = 8
    require_numbers                  = true
    require_uppercase                = true
    require_symbols                  = true
    temporary_password_validity_days = 90
  }

  verification_message_template {
    email_message = templatefile("${path.module}/email-templates/password-reset.html", { base_url = local.base_url})
  }

  email_verification_subject = "Reset your FYLD password"

  admin_create_user_config {
    invite_message_template {
      email_message = templatefile("${path.module}/email-templates/setup-user.html", { base_url = local.base_url})
      email_subject = "Setting up your FYLD account"
      sms_message   = "Your username is {username} and temporary password is {####}"
    }
  }

  lifecycle {
    ignore_changes = [
      lambda_config,
    ]
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "default" {
  name                                 = "${var.project_name}-${var.env}-app-client"
  user_pool_id                         = aws_cognito_user_pool.default.id
  generate_secret                      = false
  explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows                  = ["code"]
  callback_urls                        = ["${local.base_url}/login", "sitestream://callback", "http://localhost:3000/login"]
  default_redirect_uri                 = "${local.base_url}/login"
  logout_urls                          = ["${local.base_url}/login", "sitestream://signout", "http://localhost:3000/login"]
  prevent_user_existence_errors        = "ENABLED"
  allowed_oauth_flows_user_pool_client = true
  read_attributes = [
    "email",
    "family_name",
    "given_name",
    "custom:orgUuid",
    "custom:authChallenge",
  ]
  supported_identity_providers = compact(concat(local.oidc_providers, keys(local.saml_providers)))
  depends_on                   = [aws_cognito_identity_provider.oidc, aws_cognito_identity_provider.saml]
}

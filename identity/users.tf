resource "aws_iam_user" "circleci" {
  name = "circle_ci"
}

resource "aws_iam_group_membership" "circleci" {
  name = "circleci"

  users = [
    aws_iam_user.circleci.name,
  ]

  group = aws_iam_group.circleci.name
}

resource "aws_iam_user" "terraform" {
  name = "terraform"
}

resource "aws_iam_group_membership" "terraform" {
  name = "terraform"

  users = [
    aws_iam_user.terraform.name,
  ]

  group = aws_iam_group.terraform.name
}

module "tamas" {
  source    = "cloudposse/iam-user/aws"

  name      = "tamas@fyld.ai"
  user_name = "tamas@fyld.ai"
  pgp_key   = "keybase:tamas_fyld"
  groups    = ["developers", "security", "admin"]
}

output "tamas" {
  description = "Decrypt command"
  value       = module.tamas.keybase_password_decrypt_command
}

module "daniel" {
  source    = "cloudposse/iam-user/aws"

  name      = "daniel@fyld.ai"
  user_name = "daniel@fyld.ai"
  pgp_key   = "keybase:danielm_fyld"
  groups    = ["developers", "security", "admin"]
}

output "daniel" {
  description = "Decrypt command"
  value       = module.daniel.keybase_password_decrypt_command
}

module "aleks" {
  source    = "cloudposse/iam-user/aws"

  name      = "aleks@fyld.ai"
  user_name = "aleks@fyld.ai"
  pgp_key   = "keybase:aleks_fyld"
  groups    = ["developers"]
}

output "aleks" {
  description = "Decrypt command"
  value       = module.aleks.keybase_password_decrypt_command
}
  
module "ylenio" {
  source    = "cloudposse/iam-user/aws"

  name      = "ylenio@fyld.ai"
  user_name = "ylenio@fyld.ai"
  pgp_key   = "keybase:ylenio"
  groups    = ["developers"]
}

output "ylenio" {
  description = "Decrypt command"
  value       = module.ylenio.keybase_password_decrypt_command
}

module "shane" {
  source    = "cloudposse/iam-user/aws"

  name      = "shane@fyld.ai"
  user_name = "shane@fyld.ai"
  pgp_key   = "keybase:shane_fyld"
  groups    = ["developers"]
}

output "shane" {
  description = "Decrypt command"
  value       = module.shane.keybase_password_decrypt_command
}

module "juan" {
  source    = "cloudposse/iam-user/aws"

  name      = "jperozo@aclti.com"
  user_name = "jperozo@aclti.com"
  pgp_key   = "keybase:jperozo"
  groups    = ["developers", "security", "admin"]
}

output "juan" {
  description = "Decrypt command"
  value       = module.juan.keybase_password_decrypt_command
}

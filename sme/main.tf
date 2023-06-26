terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sitestream"

    workspaces {
      name = "sme"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73.0"
    }
  }
}

module "security_baseline" {
  source = "../modules/security_baseline"

  target_regions = ["eu-west-1"]

  providers = {
    aws                = aws
    aws.ap-northeast-1 = aws.ap-northeast-1
    aws.ap-northeast-2 = aws.ap-northeast-2
    aws.ap-south-1     = aws.ap-south-1
    aws.ap-southeast-1 = aws.ap-southeast-1
    aws.ap-southeast-2 = aws.ap-southeast-2
    aws.ca-central-1   = aws.ca-central-1
    aws.eu-central-1   = aws.eu-central-1
    aws.eu-north-1     = aws.eu-north-1
    aws.eu-west-1      = aws.eu-west-1
    aws.eu-west-2      = aws.eu-west-2
    aws.eu-west-3      = aws.eu-west-3
    aws.sa-east-1      = aws.sa-east-1
    aws.us-east-1      = aws.us-east-1
    aws.us-east-2      = aws.us-east-2
    aws.us-west-1      = aws.us-west-1
    aws.us-west-2      = aws.us-west-2
  }
}

module "roles" {
  source              = "../modules/rolesv2"
  identity_account_id = var.IDENTITY_ACCOUNT_ID
  env                 = var.ENV
  project_name        = var.PROJECT_NAME
}

# TODO: 2021-07-13: Certificate domain limit hit in us-east-1 (quota was originally updated ONLY in eu-west-1...)
# Add the following subdomains:
# "forefront.fyld.ai", "thameswater.fyld.ai"

module "fyld-ai-routing" {
  source              = "../modules/fyld-ai-routing"
  environment         = var.ENV
  hosted_zone_domain  = "fyld.ai"
  primary_domain_name = "sme.fyld.ai"
  subdomains = [
    "rhp.fyld.ai", "cappers.fyld.ai", "demo.fyld.ai", "medcu.fyld.ai", "nmcn-water.fyld.ai", "fernsgroup.fyld.ai", "morrisonws.fyld.ai",
    "amey.fyld.ai", "sgncs.fyld.ai", "ferrovial.fyld.ai", "lanes-group.fyld.ai", "irish-water.fyld.ai", "sandbox.fyld.ai", "veolia.fyld.ai",
    "morrisonws-uu.fyld.ai", "morrisonws-yw-p4y.fyld.ai", "morrisonws-yw-wsp.fyld.ai", "veolia-brettex.fyld.ai", "gallifordtry-exewater.fyld.ai",
    "veolia-mechservices.fyld.ai", "trinity.fyld.ai", "kierhighways-area13.fyld.ai", "kierhighways-a585.fyld.ai", "cadent-pegasus.fyld.ai",
    "cadent-daneways.fyld.ai", "morrisonws-ww.fyld.ai", "veolia-hazardous-waste.fyld.ai", "sse-networks.fyld.ai", "kierhighways-area3.fyld.ai",
    "ww-nos.fyld.ai", "lanes-i.fyld.ai", "morrisonws-ww-rm.fyld.ai", "morrisonws-ww-ds.fyld.ai", "morrisonws-cwa.fyld.ai", "mercedesamgf1.fyld.ai",
    "pmp-utilities.fyld.ai", "caruna.fyld.ai", "kierutilities.fyld.ai", "southernwater.fyld.ai", "morrisonws-thameswater.fyld.ai", "southernwater-cleannetworks.fyld.ai",
    "nationalgridlpt.fyld.ai", "milestoneinfra.fyld.ai", "transgrid.fyld.ai", "yorkshirewater-cleannetworks.fyld.ai", "southwestwater.fyld.ai",
    "clc-utilities.fyld.ai", "sgn-h100.fyld.ai", "morrisonws-thameswater.fyld.ai", "mts.fyld.ai", "colas.fyld.ai", "cappagh-browne.fyld.ai",
    "yorkshirewater.fyld.ai"
  ]
  open_firebase_ips = ["151.101.1.195", "151.101.65.195"]

  providers = {
    aws           = aws
    aws.eu-west-1 = aws.eu-west-1
    aws.us-east-1 = aws.us-east-1
  }
}

module "networking" {
  source       = "../modules/networking"
  env          = var.ENV
  project_name = var.PROJECT_NAME
}

module "database" {
  source                  = "../modules/database"
  project_name            = var.PROJECT_NAME
  env                     = var.ENV
  service                 = "db"
  username                = var.SME_DB_USER
  password                = var.SME_DB_PASSWORD # Only printable ASCII characters besides '/', '@', '"', ' ' may be used.
  bastion_subnet          = module.networking.public_subnets[1]
  db_subnets              = module.networking.private_subnets
  vpc_id                  = module.networking.vpc_id
  domain_zone_id          = module.fyld-ai-routing.primary_domain_zone_id
  key_file                = "../ssh/sitestream.pub"
  backup_retention_period = 30
  multi_az                = true
  encrypted_instance_type = "db.t3.medium"
  allocated_storage       = 50
  # Get below params from snowflake: "DESC INTEGRATION backend_sme;"
  snowflake_user_arn    = "arn:aws:iam::112500408651:user/henw-s-ukst1266"
  snowflake_external_id = "KQ33960_SFCRole=3_yUK1iBIo7MU2K5l/1tS4wkM7g6c="
}

module "ecr" {
  source       = "../modules/ecr"
  project_name = var.PROJECT_NAME
  env          = var.ENV
}

module "ecr-fyld-brain" {
  source       = "../modules/ecr"
  project_name = var.PROJECT_NAME
  env          = "${var.ENV}-fyld-brain"
}

module "ecs" {
  source                        = "../modules/ecs"
  project_name                  = var.PROJECT_NAME
  env                           = var.ENV
  vpc_id                        = module.networking.vpc_id
  public_subnets                = module.networking.public_subnets
  protected_subnets             = module.networking.protected_subnets.*.id
  database_security_group       = module.database.elb_security_group
  elastiache_security_group     = module.elasticache_redis.security_group
  repository_url                = module.ecr.repository_url
  lb_certificate_arn            = module.fyld-ai-routing.regional_certificate_arn
  cf_certificate_arn            = module.fyld-ai-routing.cloudfront_certificate_arn
  primary_root_domain           = "api"
  domain_zone_id                = module.fyld-ai-routing.primary_domain_zone_id
  domain_names                  = ["api.sme.fyld.ai"]
  waf_enabled                   = true
  ecs_instance_max_size         = 4
  ecs_instance_desired_capacity = 3
  ecs_task_count                = 3
  ecs_scaling_max_capacity      = 3
  ecs_scaling_target_capacity   = 3
}

module "fyld-brain" {
  source                    = "../modules/fyld-brain"
  project_name              = var.PROJECT_NAME
  env                       = var.ENV
  vpc_id                    = module.networking.vpc_id
  public_subnets            = module.networking.public_subnets
  protected_subnets         = module.networking.protected_subnets.*.id
  database_security_group   = module.database.elb_security_group
  elastiache_security_group = module.elasticache_redis.security_group
  repository_url            = module.ecr-fyld-brain.repository_url
  cpu                       = var.ECS_FYLD_BRAIN_CPU
  memory                    = var.ECS_FYLD_BRAIN_MEMORY
}

module "static_resources" {
  source                  = "../modules/static_resources"
  project_name            = var.PROJECT_NAME
  env                     = var.ENV
  cloudfront_domain_names = ["static.${var.ENV}.fyld.ai", ]
  primary_root_domain     = "static"
  acm_certificate_arn     = module.fyld-ai-routing.cloudfront_certificate_arn
  domain_zone_id          = module.fyld-ai-routing.primary_domain_zone_id
  headers_lambda          = module.headers_lambda.headers_lambda
}

module "headers_lambda" {
  source       = "../modules/headers_lambda"
  project_name = var.PROJECT_NAME
  env          = var.ENV

  providers = {
    aws = aws.us-east-1
  }
}

# TODO: 2021-07-13: Certificate domain limit hit in us-east-1 (quota was originally updated ONLY in eu-west-1...)
# Add the following subdomains:
# "forefront.fyld.ai", "thameswater.fyld.ai"

module "website" {
  source       = "../modules/website"
  project_name = var.PROJECT_NAME
  env          = var.ENV
  cloudfront_domain_names = [
    "sme.fyld.ai", "rhp.fyld.ai", "cappers.fyld.ai", "demo.fyld.ai", "medcu.fyld.ai", "nmcn-water.fyld.ai", "fernsgroup.fyld.ai",
    "morrisonws.fyld.ai", "amey.fyld.ai", "sgncs.fyld.ai", "ferrovial.fyld.ai", "lanes-group.fyld.ai", "irish-water.fyld.ai",
    "sandbox.fyld.ai", "veolia.fyld.ai", "morrisonws-uu.fyld.ai", "morrisonws-yw-p4y.fyld.ai", "morrisonws-yw-wsp.fyld.ai",
    "veolia-brettex.fyld.ai", "gallifordtry-exewater.fyld.ai", "veolia-mechservices.fyld.ai", "trinity.fyld.ai",
    "kierhighways-area13.fyld.ai", "kierhighways-a585.fyld.ai", "cadent-pegasus.fyld.ai", "cadent-daneways.fyld.ai",
    "morrisonws-ww.fyld.ai", "veolia-hazardous-waste.fyld.ai", "sse-networks.fyld.ai", "kierhighways-area3.fyld.ai",
    "ww-nos.fyld.ai", "lanes-i.fyld.ai", "morrisonws-ww-rm.fyld.ai", "morrisonws-ww-ds.fyld.ai", "morrisonws-cwa.fyld.ai",
    "mercedesamgf1.fyld.ai", "pmp-utilities.fyld.ai", "caruna.fyld.ai", "kierutilities.fyld.ai", "southernwater.fyld.ai",
    "morrisonws-thameswater.fyld.ai", "southernwater-cleannetworks.fyld.ai", "nationalgridlpt.fyld.ai", "milestoneinfra.fyld.ai",
    "transgrid.fyld.ai", "yorkshirewater-cleannetworks.fyld.ai", "southwestwater.fyld.ai", "clc-utilities.fyld.ai", "sgn-h100.fyld.ai",
    "morrisonws-thameswater.fyld.ai", "mts.fyld.ai", "colas.fyld.ai", "cappagh-browne.fyld.ai", "yorkshirewater.fyld.ai"
  ]
  primary_root_domain = ""
  acm_certificate_arn = module.fyld-ai-routing.cloudfront_certificate_arn
  domain_zone_ids     = module.fyld-ai-routing.domain_zones
  headers_lambda      = module.headers_lambda.headers_lambda
}

module "maestro" {
  source                                        = "../modules/maestro"
  project_name                                  = var.PROJECT_NAME
  env                                           = var.ENV
  cloudfront_domain_names                       = ["media.${var.ENV}.fyld.ai"]
  primary_root_domain                           = "media"
  acm_certificate_arn                           = module.fyld-ai-routing.cloudfront_certificate_arn
  domain_zone_id                                = module.fyld-ai-routing.primary_domain_zone_id
  cognito_user_pool_id                          = module.authentication.cognito_user_pool_id
  cognito_user_pool_client_id                   = module.authentication.cognito_user_pool_client_id
  waf_enabled                                   = true
  log_bucket                                    = module.s3_access_logs.log_bucket.id
  dynamodb_connections_read_capacity            = 2
  dynamodb_connections_write_capacity           = 10
  dynamodb_connections_secondary_read_capacity  = 2
  dynamodb_connections_secondary_write_capacity = 10
  dynamodb_nlp_metrics_hazards_read_capacity    = 2
  dynamodb_nlp_metrics_hazards_write_capacity   = 2
  dynamodb_nlp_metrics_controls_read_capacity   = 2
  dynamodb_nlp_metrics_controls_write_capacity  = 2
  backup_security_group_id                      = module.database.lambda_backup_security_group
  lambda_clamav_security_group_id               = module.database.lambda_clamav_security_group
  lambda_database_access_security_group_id      = module.database.lambda_database_access_security_group
  protected_subnet_ids                          = module.networking.protected_subnets.*.id
  fyld_brain_sqs_queue_arn                      = module.fyld-brain.fyld_brain_sqs_queue_arn
}

module "authentication" {
  source              = "../modules/authenticationv2"
  project_name        = var.PROJECT_NAME
  env                 = var.ENV
  identity_account_id = var.IDENTITY_ACCOUNT_ID
  base_url            = "${var.ENV}.fyld.ai"
}

module "s3_access_logs" {
  source       = "../modules/s3_access_logs"
  project_name = var.PROJECT_NAME
  env          = var.ENV
}

module "elasticache_redis" {
  source          = "../modules/elasticache_redis"
  project_name    = var.PROJECT_NAME
  env             = var.ENV
  subnet_ids      = module.networking.private_subnets
  security_groups = [module.database.elb_security_group]
  vpc_id          = module.networking.vpc_id
}

# TODO: Uncomment to enable live db replication to Snowflake
# module "snowflake_kafka_cluster" {
#   source                     = "../modules/mks"
#   project_name               = var.PROJECT_NAME
#   env                        = var.ENV
#   subnet_ids                 = module.networking.private_subnets
#   vpc_id                     = module.networking.vpc_id
#   // TODO: Remove public subnet once user data is automated
#   host_subnet_id             = module.networking.public_subnets[0]
#   db_username                = var.SME_DB_USER
#   db_password                = var.SME_DB_PASSWORD
#   db_host                    = "db.sme.fyld.ai"
#   database_sg                = module.database.rds_access_security_group
#   volume_size                = 200
#   SNOWFLAKE_SYNC_PRIVATE_KEY = var.SNOWFLAKE_SYNC_PRIVATE_KEY
#   SNOWFLAKE_SYNC_PASSWORD    = var.SNOWFLAKE_SYNC_PASSWORD
# }

# Uncomment if an host with static IP is needed

# module "ftp" {
#   source         = "../modules/ftp"
#   project_name   = var.PROJECT_NAME
#   env            = var.ENV
#   ftp_subnet     = module.networking.public_subnets[1]
#   vpc_id         = module.networking.vpc_id
#   domain_zone_id = module.fyld-ai-routing.primary_domain_zone_id
#   key_file       = "../ssh/fyld_ftp.pub"
# }

module "iam_rotator" {
  source                 = "../modules/iam_rotator"
  project_name           = var.PROJECT_NAME
  env                    = var.ENV
  slack_bot_access_token = var.SLACK_BOT_ACCESS_TOKEN
}

module "android_build" {
  source       = "../modules/android_build"
  project_name = var.PROJECT_NAME
  env          = var.ENV
}

module "pgbouncer" {
  source                  = "../modules/pgbouncer"
  project_name            = var.PROJECT_NAME
  env                     = var.ENV
  pgbouncer_subnet        = module.networking.public_subnets[1]
  vpc_id                  = module.networking.vpc_id
  domain_zone_id          = module.fyld-ai-routing.primary_domain_zone_id
  key_file                = "../ssh/pgbouncer.pub"
  db_password             = var.SME_DB_PASSWORD
  db_host                 = "db.sme.fyld.ai"
  bouncer_password        = var.BOUNCER_PASSWORD
  database_security_group = module.database.elb_security_group
}

module "sagemaker" {
  source       = "../modules/sagemaker"
  project_name = var.PROJECT_NAME
  env          = var.ENV
}

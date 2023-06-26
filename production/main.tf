terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sitestream"

    workspaces {
      name = "production"
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

module "routing" {
  source            = "../modules/routing"
  environment       = var.ENV
  open_firebase_ips = ["151.101.1.195", "151.101.65.195"]
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
  username                = var.PRODUCTION_DB_USER
  password                = var.PRODUCTION_DB_PASSWORD
  bastion_subnet          = module.networking.public_subnets[1]
  db_subnets              = module.networking.private_subnets
  vpc_id                  = module.networking.vpc_id
  domain_zone_id          = module.routing.domain_zone_id
  key_file                = "../ssh/sitestream.pub"
  backup_retention_period = 30
  multi_az                = true
  encrypted_instance_type = "db.t4g.2xlarge"
  allocated_storage       = 50
  # Get below params from snowflake: "DESC INTEGRATION backend_production;"
  snowflake_user_arn    = "arn:aws:iam::112500408651:user/henw-s-ukst1266"
  snowflake_external_id = "KQ33960_SFCRole=3_2m5r8mJt1JxBiBdqPvXSyS2DPb8="
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
  lb_certificate_arn            = "arn:aws:acm:eu-west-1:734907094745:certificate/d0432481-5fb0-4d35-a85d-8b6166e71e10" #TBD: this should be programmatic
  cf_certificate_arn            = "arn:aws:acm:us-east-1:734907094745:certificate/7652a183-4a08-4076-8a91-1c75e3b82b15" #TBD: this should be programmatic
  primary_root_domain           = "api"
  domain_zone_id                = module.routing.domain_zone_id
  domain_names                  = ["api.sitestream.app", "api.production.sitestream.app"]
  waf_enabled                   = true
  ecs_instance_min_size         = 3
  ecs_instance_max_size         = 6
  ecs_instance_desired_capacity = 6
  ecs_scaling_min_capacity      = 3
  ecs_scaling_max_capacity      = 6
  ecs_scaling_target_capacity   = 4
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
  cloudfront_domain_names = ["static.production.sitestream.app", "static.sitestream.app"]
  primary_root_domain     = "static"
  acm_certificate_arn     = "arn:aws:acm:us-east-1:734907094745:certificate/7652a183-4a08-4076-8a91-1c75e3b82b15" #TBD: this should be programmatic
  domain_zone_id          = module.routing.domain_zone_id
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

module "website" {
  source                  = "../modules/website"
  project_name            = var.PROJECT_NAME
  env                     = var.ENV
  cloudfront_domain_names = ["www.production.sitestream.app", "www.sitestream.app"]
  primary_root_domain     = "www"
  acm_certificate_arn     = "arn:aws:acm:us-east-1:734907094745:certificate/1c6fac49-c7fb-4f5f-b6d0-723c0e46acce" #TBD: this should be programmatic
  domain_zone_ids         = { (var.ENV) : { "zone_id" = module.routing.domain_zone_id } }
  headers_lambda          = module.headers_lambda.headers_lambda
}

module "maestro" {
  source                                        = "../modules/maestro"
  project_name                                  = var.PROJECT_NAME
  env                                           = var.ENV
  cloudfront_domain_names                       = ["media.production.sitestream.app", "media.sitestream.app"]
  primary_root_domain                           = "media"
  acm_certificate_arn                           = "arn:aws:acm:us-east-1:734907094745:certificate/7652a183-4a08-4076-8a91-1c75e3b82b15" #TBD: this should be programmatic
  domain_zone_id                                = module.routing.domain_zone_id
  cognito_user_pool_id                          = module.authentication.cognito_user_pool_id
  cognito_user_pool_client_id                   = module.authentication.cognito_user_pool_client_id
  waf_enabled                                   = true
  log_bucket                                    = module.s3_access_logs.log_bucket.id
  dynamodb_connections_read_capacity            = 1
  dynamodb_connections_write_capacity           = 5
  dynamodb_connections_secondary_read_capacity  = 3
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
  source              = "../modules/authentication"
  project_name        = var.PROJECT_NAME
  env                 = var.ENV
  identity_account_id = var.IDENTITY_ACCOUNT_ID
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
#   db_username                = var.PRODUCTION_DB_USER
#   db_password                = var.PRODUCTION_DB_PASSWORD
#   db_host                    = "db.production.sitestream.app"
#   database_sg                = module.database.rds_access_security_group
#   SNOWFLAKE_SYNC_PRIVATE_KEY = var.SNOWFLAKE_SYNC_PRIVATE_KEY
#   SNOWFLAKE_SYNC_PASSWORD    = var.SNOWFLAKE_SYNC_PASSWORD
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

module "sagemaker" {
  source       = "../modules/sagemaker"
  project_name = var.PROJECT_NAME
  env          = var.ENV
}

module "pgbouncer" {
  source                  = "../modules/pgbouncer"
  project_name            = var.PROJECT_NAME
  env                     = var.ENV
  pgbouncer_subnet        = module.networking.public_subnets[1]
  vpc_id                  = module.networking.vpc_id
  domain_zone_id          = module.routing.domain_zone_id
  key_file                = "../ssh/pgbouncer.pub"
  db_password             = var.PRODUCTION_DB_PASSWORD
  db_host                 = "db.production.sitestream.app"
  bouncer_password        = var.BOUNCER_PASSWORD
  database_security_group = module.database.elb_security_group
}

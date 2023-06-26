terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sitestream"

    workspaces {
      name = "staging"
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
  username                = var.STAGING_DB_USER
  password                = var.STAGING_DB_PASSWORD
  bastion_subnet          = module.networking.public_subnets[1]
  db_subnets              = module.networking.private_subnets
  vpc_id                  = module.networking.vpc_id
  domain_zone_id          = module.routing.domain_zone_id
  key_file                = "../ssh/sitestream.pub"
  backup_retention_period = 7
  allocated_storage       = 30
  # Get below params from snowflake: "DESC INTEGRATION backend_staging;"
  snowflake_user_arn    = "arn:aws:iam::112500408651:user/henw-s-ukst1266"
  snowflake_external_id = "KQ33960_SFCRole=3_qwYfNSeEFhObq/qpckY1zBfs7e0="
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
  source                    = "../modules/ecs"
  project_name              = var.PROJECT_NAME
  env                       = var.ENV
  vpc_id                    = module.networking.vpc_id
  public_subnets            = module.networking.public_subnets
  protected_subnets         = module.networking.protected_subnets.*.id
  database_security_group   = module.database.elb_security_group
  elastiache_security_group = module.elasticache_redis.security_group
  repository_url            = module.ecr.repository_url
  lb_certificate_arn        = "arn:aws:acm:eu-west-1:116977071601:certificate/69c80ffe-5f32-4cd4-88f8-74b93e360564" #TBD: this should be programmatic
  cf_certificate_arn        = "arn:aws:acm:us-east-1:116977071601:certificate/d9829dda-15fb-4e85-8417-a743cdb9cebf" #TBD: this should be programmatic
  primary_root_domain       = "api"
  domain_zone_id            = module.routing.domain_zone_id
  domain_names              = ["api.staging.sitestream.app"]
  waf_enabled               = true
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
  cloudfront_domain_names = ["static.staging.sitestream.app"]
  primary_root_domain     = "static"
  acm_certificate_arn     = "arn:aws:acm:us-east-1:116977071601:certificate/d9829dda-15fb-4e85-8417-a743cdb9cebf" #TBD: this should be programmatic
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

module "iam_rotator" {
  source                 = "../modules/iam_rotator"
  project_name           = var.PROJECT_NAME
  env                    = var.ENV
  slack_bot_access_token = var.SLACK_BOT_ACCESS_TOKEN
}

module "website" {
  source                  = "../modules/website"
  project_name            = var.PROJECT_NAME
  env                     = var.ENV
  cloudfront_domain_names = ["www.staging.sitestream.app"]
  primary_root_domain     = "www"
  acm_certificate_arn     = "arn:aws:acm:us-east-1:116977071601:certificate/d9829dda-15fb-4e85-8417-a743cdb9cebf" #TBD: this should be programmatic
  domain_zone_ids         = { (var.ENV) : { "zone_id" = module.routing.domain_zone_id } }
  headers_lambda          = module.headers_lambda.headers_lambda
}

module "maestro" {
  source                                        = "../modules/maestro"
  project_name                                  = var.PROJECT_NAME
  env                                           = var.ENV
  cloudfront_domain_names                       = ["media.staging.sitestream.app"]
  primary_root_domain                           = "media"
  acm_certificate_arn                           = "arn:aws:acm:us-east-1:116977071601:certificate/d9829dda-15fb-4e85-8417-a743cdb9cebf" #TBD: this should be programmatic
  domain_zone_id                                = module.routing.domain_zone_id
  cognito_user_pool_id                          = module.authentication.cognito_user_pool_id
  cognito_user_pool_client_id                   = module.authentication.cognito_user_pool_client_id
  waf_enabled                                   = true
  log_bucket                                    = module.s3_access_logs.log_bucket.id
  dynamodb_connections_read_capacity            = 1
  dynamodb_connections_write_capacity           = 1
  dynamodb_connections_secondary_read_capacity  = 1
  dynamodb_connections_secondary_write_capacity = 1
  dynamodb_nlp_metrics_hazards_read_capacity    = 1
  dynamodb_nlp_metrics_hazards_write_capacity   = 1
  dynamodb_nlp_metrics_controls_read_capacity   = 1
  dynamodb_nlp_metrics_controls_write_capacity  = 1
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
  size            = var.REDIS_SIZE
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
#   db_username                = var.STAGING_DB_USER
#   db_password                = var.STAGING_DB_PASSWORD
#   db_host                    = "db.staging.sitestream.app"
#   database_sg                = module.database.rds_access_security_group
#   SNOWFLAKE_SYNC_PRIVATE_KEY = var.SNOWFLAKE_SYNC_PRIVATE_KEY
#   SNOWFLAKE_SYNC_PASSWORD    = var.SNOWFLAKE_SYNC_PASSWORD
# }

module "monitoring" {
  source       = "../modules/monitoring"
  project_name = var.PROJECT_NAME
  env          = var.ENV
}

module "sagemaker" {
  source       = "../modules/sagemaker"
  project_name = var.PROJECT_NAME
  env          = var.ENV
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
  domain_zone_id          = module.routing.domain_zone_id
  key_file                = "../ssh/pgbouncer.pub"
  db_password             = var.STAGING_DB_PASSWORD
  db_host                 = "db.staging.sitestream.app"
  bouncer_password        = var.STAGING_DB_PASSWORD
  database_security_group = module.database.elb_security_group
}

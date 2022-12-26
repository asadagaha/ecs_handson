provider "aws" {
  region = var.region
}

module "vpc" {
  source             = "./module/vpc"
  project            = var.project
  env                = var.env
  region = var.region
  vpc_endpoint_sg_id = module.security_group.vpc_endpoint_sg_id
}
module "iam" {
  source                       = "./module/iam"
  project                      = var.project
  env                          = var.env
  aws_cognito_identity_pool_id = module.cognito.aws_cognito_identity_pool_id
  dynamo_db_arn                = module.dynamodb.dynamo_db_arn
}
module "security_group" {
  source   = "./module/security_group"
  project  = var.project
  env      = var.env
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}
module "cognito" {
  source           = "./module/cognito"
  project          = var.project
  env              = var.env
  region           = var.region
  admin_user_email = var.cognito_admin_user_email
}
module "dynamodb" {
  source  = "./module/dynamodb"
  project = var.project
  env     = var.env
}
module "cloudwatch" {
  source  = "./module/cloudwatch"
  project = var.project
  env     = var.env
}
module "elb" {
  source     = "./module/elb"
  project    = var.project
  env        = var.env
  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.subned_public_1a_id, module.vpc.subned_public_1c_id]
  alb_sg_id  = module.security_group.alb_sg_id
  acm_arn    = var.acm_arn
}
module "ecr" {
  source             = "./module/ecr"
  project            = var.project
  env                = var.env
  web_container_name = var.web_container_name
}
module "ecs" {
  source                       = "./module/ecs"
  account_id                   = local.account_id
  region                       = var.region
  project                      = var.project
  env                          = var.env
  vpc_id                       = module.vpc.vpc_id
  target_group_arn             = module.elb.target_group_arn
  subnet_ids                   = [module.vpc.subned_public_1a_id, module.vpc.subned_public_1c_id]
  web_container_name           = var.web_container_name
  ecs_sg_id                    = module.security_group.ecs_sg_id
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  cloudwatch_log_group_for_ecs = module.cloudwatch.cloudwatch_log_group_for_ecs
}

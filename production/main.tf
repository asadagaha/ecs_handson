provider "aws" {
  region = var.region
}

module "network" {
  source             = "../module/network"
  project            = var.project
  env                = local.env
  vpc_endpoint_sg_id = module.security_group.vpc_endpoint_sg_id
}
module "iam" {
  source  = "../module/iam"
  project = var.project
  env     = local.env
}
module "security_group" {
  source   = "../module/security_group"
  project  = var.project
  env      = local.env
  vpc_id   = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
}

module "cloudwatch" {
  source  = "../module/cloudwatch"
  project = var.project
  env     = local.env
}
module "elb" {
  source              = "../module/elb"
  project             = var.project
  env                 = local.env
  vpc_id              = module.network.vpc_id
  subned_public_1a_id = module.network.subned_public_1a_id
  subned_public_1c_id = module.network.subned_public_1c_id
  alb_sg_id           = module.security_group.alb_sg_id
}
module "ecr" {
  source             = "../module/ecr"
  project            = var.project
  env                = local.env
  web_container_name = var.web_container_name
}
module "ecs" {
  source                       = "../module/ecs"
  account_id                   = local.account_id
  region                       = var.region
  project                      = var.project
  env                          = local.env
  vpc_id                       = module.network.vpc_id
  target_group_arn             = module.elb.target_group_arn
  subned_public_1a_id          = module.network.subned_public_1a_id
  subned_public_1c_id          = module.network.subned_public_1c_id
  web_container_name           = var.web_container_name
  ecs_sg_id                    = module.security_group.ecs_sg_id
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  cloudwatch_log_group_for_ecs = module.cloudwatch.cloudwatch_log_group_for_ecs
}

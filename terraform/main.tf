variable "env" {}
variable "apache_container_name" {}
variable "apache_container_image_uri" {}
variable "region" {}

provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
  env  = var.env
}
module "iam" {
  source = "./modules/iam"
  env  = var.env
}
module "security_group" {
  source = "./modules/security_group"
  env  = var.env
  vpc_id = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  env  = var.env
}
module "elb" {
  source = "./modules/elb"
  env  = var.env
  vpc_id = module.network.vpc_id
  subned_public_1a_id = module.network.subned_public_1a_id
  subned_public_1c_id = module.network.subned_public_1c_id
  alb_sg_id = module.security_group.alb_sg_id
}
module "ecs" {
  source = "./modules/ecs"
  env  = var.env
  vpc_id = module.network.vpc_id
  target_group_arn = module.elb.target_group_arn
  subned_public_1a_id = module.network.subned_public_1a_id
  subned_public_1c_id = module.network.subned_public_1c_id
  apache_container_name = var.apache_container_name
  apache_container_image_uri = var.apache_container_image_uri  
  ecs_sg_id = module.security_group.ecs_sg_id
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  cloudwatch_log_group_for_ecs = module.cloudwatch.cloudwatch_log_group_for_ecs
}

module vpc_endpoint {
  source = "./modules/vpc_endpoint"
  env  = var.env
  vpc_id = module.network.vpc_id
  subned_public_1a_id = module.network.subned_public_1a_id
  subned_public_1c_id = module.network.subned_public_1c_id
  route_table_id = module.network.route_table_id
  vpc_endpoint_sg_id = module.security_group.vpc_endpoint_sg_id
}
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
  apache_container_name = var.apache_container_name
  apache_container_image_uri = var.apache_container_image_uri
  ecs_sg_id = module.security.ecs_sg_id
  alb_sg_id = module.security.alb_sg_id
}
module "security" {
  source = "./modules/security"
  env  = var.env
  vpc_id = module.network.vpc_id
}

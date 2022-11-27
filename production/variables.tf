variable "project" {}
variable "region" {}
variable "web_container_name" {}
variable "acm_arn" {}
variable "account_id" {}

locals {
    env = "prod"
}
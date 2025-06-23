## NextGeneration VPC Module
locals {
  tmp_extra_public_routes = {}
  tmp_extra_private_routes = {}

  vpc_extra_public_routes = merge(var.vpc_extra_public_routes, local.tmp_extra_public_routes)
  vpc_extra_private_routes = merge(var.vpc_extra_public_routes, local.tmp_extra_private_routes)
}
# VPC Prepared for future use
module "tf-aws-vpc" {
  source                             = "./modules/tf-module-vpc"

  name_prefix                        = "${var.name_prefix}"
  aws_region                         = var.region

  availability_zones                 = var.availability_zone_names
  cidr_block                         = var.vpc_cidr_block
  public_subnet_cidrs                = var.vpc_public_subnet_cidrs
  private_subnets_cidrs              = var.vpc_private_subnet_cidrs

  enable_private_network             = var.enable_private_network
  enable_nat_gateways                = var.vpc_enable_nat_gateways

  enable_public_ip_autoassign        = var.enable_auto_assigning_ips

  enable_sqs_sns_vpc_endpoints       = var.vpc_enable_sqs_sns_vpc_endpoints
  enable_s3_vpc_endpoint             = var.vpc_enable_s3_vpc_endpoint
  enable_ecr_vpc_endpoints           = var.vpc_enable_ecr_vpc_endpoints
  vpc_ecr_endpoint_security_groups   = var.vpc_ecr_endpoint_security_groups

  vpc_peering_connections_sameregion = var.vpc_peering_connections_sameregion

  extra_public_routes                = local.vpc_extra_public_routes
  extra_private_routes               = local.vpc_extra_private_routes

  public_subnet_tags                 = var.vpc_public_subnet_tags
  private_subnet_tags                = var.vpc_private_subnet_tags
  global_tags                        = var.global_tags
}

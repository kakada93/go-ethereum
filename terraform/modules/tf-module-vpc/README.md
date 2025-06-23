# tf-module-vpc


## Versioning

### v1.1.0
  - Added two new variables and routing for Site2Site VPNs
    vpn_gateway_id, vpn_gateway_routing_cidr
### v1.1.1
  - Removed site2site routes from vpc module and moved them to the site2site module to avoid racing conditions
### v1.1.2
  - VPC Route lifecycle policy added
### v1.1.3
  - VPC Route lifecycle removed and aws_route added instead of in-table-route to achieve consistency
### v1.1.4
  - VPC Peering Now Also creates routes in the public subnets
### v1.1.6
  - VPC Peering Routing worked without overwriting existing routes in the table
### v1.1.7
  - Adding extra_public_routes and extra_private_routes variables that can be specified optionally
### v1.1.8
  - Same as 1.1.7
### v1.1.9
  - v1.1.9 VPC Fixing small issue that causes inconsistency in state
### v1.2.0
  - v1.2.0 VPC Module Extra Private/Public routes adjusted so that network interface(ec2) id can be specified

### v1.2.1
  - VPC Endpoint for S3 added
  - VPC Endpoints adjusted

## Example Usage


Module Definition

---

```
module "vpc" {
  #source                             = "git::https://gitlab.itgix.com/educatedguessteam/tf-modules/tf-module-vpc.git?ref=main"
  source                             = "git::ssh://git@gitlab.itgix.com/educatedguessteam/tf-modules/tf-module-vpc.git"

  name_prefix                        = var.name_prefix
  aws_region                         = var.aws_region
  availability_zones                 = var.vpc_availability_zones
  cidr_block                         = var.vpc_cidr_block
  public_subnet_cidrs                = var.vpc_public_subnet_cidrs
  private_subnets_cidrs              = var.vpc_private_subnet_cidrs

  enable_private_network             = var.vpc_enable_private_network
  enable_nat_gateways                = var.vpc_enable_nat_gateways

  enable_public_ip_autoassign        = var.vpc_enable_public_ip_autoassign

  enable_ecr_vpc_endpoints           = var.vpc_enable_ecr_vpc_endpoints
  vpc_ecr_endpoint_security_groups   = var.vpc_ecr_endpoint_security_groups

  vpc_peering_connections_sameregion = var.vpc_peering_connections_sameregion

  # Site2Site VPN Routing
  vpn_gateway_id                     = try(module.site2site.vpn_gateway_id, "")
  vpn_gateway_routing_cidr           = try(module.site2site.vpn_gateway_routing_cidr, "")


  public_subnet_tags                 = var.vpc_public_subnet_tags
  private_subnet_tags                = var.vpc_private_subnet_tags
  global_tags                        = var.global_tags
}
```

Variables Example

---

```
name_prefix                        = "itgix-sandbox"
aws_region                         = "eu-west-1"

vpc_availability_zones             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
vpc_cidr_block                     = "10.10.0.0/16"
vpc_public_subnet_cidrs            = ["10.10.0.0/22","10.10.4.0/22","10.10.8.0/22"]
vpc_private_subnet_cidrs           = ["10.10.12.0/22","10.10.16.0/22","10.10.20.0/22"]

vpc_enable_private_network         = true
vpc_enable_nat_gateways            = true

vpc_enable_public_ip_autoassign    = true

vpc_enable_ecr_vpc_endpoints       = false
vpc_ecr_endpoint_security_groups   = []

vpc_peering_connections_sameregion = {
  #same_region_peer = {
  #  peer_vpc_id           = "vpc-id-of-the-vpc"
  #  peer_cidr_block       = "172.40.0.0/16"
  #  remote_dns_resolution = false
  #}
}
extra_private_routes = {
  route1 = {
    remote_cidr = "10.42.0.0/18"
    vpc_peering_connection_id = "some-Id"
  }
}
extra_public_routes = {
  route1 = {
    remote_cidr = "10.42.0.0/18"
    vpc_peering_connection_id = "some-Id"
  }
}
vpc_public_subnet_tags             = {}
vpc_private_subnet_tags            = {}
global_tags                        = { Project = "itgix-sandbox" }
```

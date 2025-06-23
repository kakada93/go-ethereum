region                  = "eu-central-1"

global_tags             = {
    project     = "lm-dev-tf"
    description = "Managed by Terraform"
}
name_prefix             = "lm-dev-tf"
environment             = "dev"
project                 = "lm-dev-tf"

#
# VPC Variables
#
enable_auto_assigning_ips = true
enable_private_network    = true
vpc_enable_nat_gateways   = true
availability_zone_names   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
cidr_prefix               = "10.10"
vpc_cidr_block            = "10.10.0.0/16"
vpc_public_subnet_cidrs   = ["10.10.0.0/22", "10.10.4.0/22", "10.10.8.0/22"]
vpc_private_subnet_cidrs  = ["10.10.12.0/22", "10.10.16.0/22", "10.10.20.0/22"]
vpc_enable_sqs_sns_vpc_endpoints = false
vpc_enable_s3_vpc_endpoint       = false
vpc_enable_ecr_vpc_endpoints     = false
vpc_ecr_endpoint_security_groups = []
vpc_public_subnet_tags             = {
  "kubernetes.io/role/elb" = "1"
  "kubernetes.io/cluster/lm-dev-eks-ng" = "owned"
} 
vpc_private_subnet_tags            = {
  "kubernetes.io/role/internal-elb" = "1"
  "kubernetes.io/cluster/lm-dev-eks-ng" = "owned"
}   
vpc_extra_public_routes = {}
vpc_extra_private_routes = {}
vpc_peering_connections_sameregion = {}


# EKS NG vars
eks_cluster_admins      = ["lm-dev-local-terraform"]
eks_cluster_admin_roles = ["AdministratorAccess"]
eks_cluster_name        = "lm-dev-eks"
eks_cluster_version     = "1.31"

eks_worker_ssh_key             = ""
eks_enable_worker_node_group   = true
eks_worker_instance_type       = ["m6a.large"]
eks_worker_min_nodes_count     = 1
eks_worker_max_nodes_count     = 5
eks_worker_desired_nodes_count = 1
eks_worker_disk_size           = "80"
eks_worker_disk_type           = "gp2"

eks_infra_ssh_key             = ""
eks_enable_infra_node_group   = false
eks_infra_instance_type       = ["m6a.large"]
eks_infra_min_nodes_count     = 3
eks_infra_max_nodes_count     = 6
eks_infra_desired_nodes_count = 6
eks_infra_disk_size           = "60"
eks_infra_disk_type           = "gp2"


variable "global_tags" {
  default = { project = "dev-new"}
  description = "Global Tags that will be applied to all resources"
}

variable "name_prefix" {
  type        = string
  default     = "dev-new"
  description = "Prefix Name for some of the resources and tags"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The Region that the AWS resources should be created in"
}

variable "domain_name" {
  type        = string
  default     = "example.com"
  description = ""
}

#
## VPC Variables
#
variable "enable_auto_assigning_ips" {
  default = true
  description = "Enable Automatic IP Assigning for public subnets"
}
variable "enable_private_network" {
  default = true
  description = "Enable Creation of Private Subnets and Nat Gateways"
}
variable "availability_zone_names" {
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
  description = "The list of required AWS Availability Zones in Region"
}
variable "cidr_prefix" {
  type        = string
  default     = "10.10"
  description = "Prefix of the CIDR, always appended by 0.0/16 in the VPC module"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.10.0.0/18"
  description = "Full Cidr block for the VPC-ng"
}
variable "vpc_public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.10.0.0/22","10.10.4.0/22","10.10.8.0/22"]
  description = "The list of public subnet cidrs with their netmasks"
}
variable "vpc_private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.10.12.0/22","10.10.16.0/22","10.10.20.0/22"]
  description = "The list of private subnet cidrs with their netmasks"
}
variable "vpc_enable_nat_gateways" {
  type        = bool
  default     = false
  description = "Defines if Nat Gateways will be created for the private network"
}
variable "vpc_enable_sqs_sns_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Enables SQS/SNS VPC Endpoints for private routing to SQS/SNS"
}
variable "vpc_enable_s3_vpc_endpoint" {
  type        = bool
  default     = false
  description = "Enables S3 VPC Endpoints for private routing to S3 apis"
}
variable "vpc_enable_ecr_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Enables ECR VPC Endpoints for private routing to ECR and DKR apis"
}
variable "vpc_ecr_endpoint_security_groups" {
  default     = []
  description = "Pass Security Groups which can use the VPC endpoint for accessing ECR through Private Network"
}
variable "vpc_public_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Tags assigned to public subnets"
}
variable "vpc_private_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Tags assigned to private subnets"
}
variable "vpc_extra_private_routes" {
  default     = {}
  description = "Extra Private Routes"
}
variable "vpc_extra_public_routes" {
  default     = {}
  description = "Extra Public Routes"
}
variable "vpc_peering_connections_sameregion" {
  default     = {}
  description = "Dictionary containing peer connections in the same region"
}



#
# EndOf VPC
#

#
# EKS NG Module
#

variable "eks_cluster_admins" {
  default     = ["dev-gitlab"]
  description = "List of cluster Admin usernames"
}
variable "eks_cluster_admin_roles" {
  default     = ["AdministratorAccess"]
  description = "List of cluster Admin usernames"
}
variable "eks_cluster_name" {
  default     = "my-cluster"
  description = "Name of the EKS Cluster"
}
variable "eks_platform" {
  default     = ""
  description = "bottlerocket for BOTTLEROCKET_x86_64 or leave empty for default type"
}
variable "eks_cluster_version" {
  default     = "1.29"
  description = "Cluster Version"
}

# Worker Group 1
variable "eks_worker_node_group_version" {
  default     = ""
  description = "Leave empty to match the Cluster version"
}
variable "eks_worker_ssh_key" {
  default     = "itgix_admins"
  description = "SSH Key with access to worker nodes"
}
variable "eks_enable_worker_node_group" {
  default     = true
  description = "Enable the creation of node grp"
}
variable "eks_worker_instance_type" {
  default     = ["t3a.large"]
  description = "Choose node grp instance types"
}
variable "eks_worker_min_nodes_count" {
  default     = "0"
  description = "Choose the minimum nodes for the asg"
}
variable "eks_worker_max_nodes_count" {
  default     = "2"
  description = "Choose the maximum nodes for the ASG"
}
variable "eks_worker_desired_nodes_count" {
  default     = "1"
  description = "Desired worker nodes count"
}
variable "eks_worker_disk_size" {
  default = "60"
  description = "Disk size in GB for the worker nodes"
}
variable "eks_worker_disk_type" {
  default = "gp2"
  description = "Storage type for the eks worker nodes"
}

# Infra Group
variable "eks_infra_node_group_version" {
  default     = ""
  description = "Leave empty to match the Cluster version"
}
variable "eks_enable_infra_node_group" {
  default     = true
  description = "Enable the creation of node grp"
}
variable "eks_infra_instance_type" {
  default     = ["t3a.large"]
  description = "Choose node grp instance types"
}
variable "eks_infra_min_nodes_count" {
  default     = "0"
  description = "Choose the minimum nodes for the asg"
}
variable "eks_infra_max_nodes_count" {
  default     = "2"
  description = "Choose the maximum nodes for the ASG"
}
variable "eks_infra_desired_nodes_count" {
  default     = "1"
  description = "Desired worker nodes count"
}
variable "eks_infra_disk_size" {
  default = "60"
  description = "Disk size in GB for the worker nodes"
}
variable "eks_infra_disk_type" {
  default = "gp2"
  description = "Storage type for the eks worker nodes"
}

variable "eks_cicd_node_group_version" {
  default     = ""
  description = "Leave empty to match the Cluster version"
}
variable "eks_enable_cicd_node_group" {
  default     = true
  description = "Enable the creation of node grp"
}
variable "eks_cicd_instance_type" {
  default     = ["t3a.large"]
  description = "Choose node grp instance types"
}
variable "eks_cicd_min_nodes_count" {
  default     = "0"
  description = "Choose the minimum nodes for the asg"
}
variable "eks_cicd_max_nodes_count" {
  default     = "2"
  description = "Choose the maximum nodes for the ASG"
}
variable "eks_cicd_desired_nodes_count" {
  default     = "1"
  description = "Desired worker nodes count"
}
variable "eks_cicd_disk_size" {
  default = "60"
  description = "Disk size in GB for the worker nodes"
}
variable "eks_cicd_disk_type" {
  default = "gp2"
  description = "Storage type for the eks worker nodes"
}



variable "eks_addon_coredns_version" {
  default     = null
  description = "If null the latest version is used"
}
variable "eks_addon_kubeproxy_version" {
  default     = null
  description = "If null the latest version is used"
}
variable "eks_addon_vpccni_version" {
  default     = null
  description = "If null the latest version is used"
}
variable "eks_addon_ebscsi_version" {
  default     = null
  description = "If null the latest version is used"
}
variable "eks_cluster_tags" {
  default     = {}
  description = "Additional Tags to add to the EKS Cluster"
}

#
# EndOf EKS
#



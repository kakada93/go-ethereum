variable "name_prefix" {
  type        = string
  default     = "itgix-sandbox"
  description = "Tag with resource name"
}
variable "aws_region" {
  type        = string
  description = "VPC Region used for VPC Endpoints to ECS and other services"
  default     = "eu-west-1"
}
variable "availability_zones" {
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  description = "The list of required AWS Availability Zones in Region"
}
variable "cidr_block" {
  type        = string
  default     = "10.10.0.0/16"
  description = "Entire CIDR Block of the VPC, containing netmask"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.10.0.0/22","10.10.4.0/22","10.10.8.0/22"]
  description = "The list of public subnet cidrs with their netmasks"
}
variable "private_subnets_cidrs" {
  type        = list(string)
  default     = ["10.10.12.0/22","10.10.16.0/22","10.10.20.0/22"]
  description = "The list of private subnet cidrs with their netmasks"
}

variable "enable_private_network" {
  type        = bool
  default     = true
  description = "Defines if private segment of the VPC should be created"
}
variable "enable_nat_gateways" {
  type        = bool
  default     = true
  description = "Defines if Nat Gateways will be created for the private network"
}

variable "enable_dns_hostnames" {
  type        = string
  description = "Defines if DNS hostbnames should be enabled for VPC"
  default     = true
}
variable "enable_public_ip_autoassign" {
  type        = bool
  default     = true
  description = "Enables auto assigning IPv4 in public subnets"
}

variable "enable_sqs_sns_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Enables sqs/sns VPC Endpoints for private routing to sqs/sns"
}
variable "enable_s3_vpc_endpoint" {
  type        = bool
  default     = false
  description = "Enables S3 VPC Endpoints for private routing to S3 apis"
}
variable "enable_ecr_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Enables ECR VPC Endpoints for private routing to ECR and DKR apis"
}
variable "vpc_ecr_endpoint_security_groups" {
  default     = []
  description = "Pass Security Groups which can use the VPC endpoint for accessing ECR through Private Network"
}
variable "vpc_peering_connections_sameregion" {
  default     = {}
  description = "Dictionary containing peer connections in the same region"
}

variable "global_tags" {
  type        = map(string)
  default     = {}
  description = "Tag(s) that must be assigned to resources"
}
variable "public_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Tags assigned to public subnets"
}
variable "private_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Tags assigned to private subnets"
}

variable "extra_public_routes" {
  default     = {}
  description = "Extra Routes to be assigned to public subnets"
}
variable "extra_private_routes" {
  default     = {}
  description = "Extra Routes to be assigned to private subnets"
}

variable "name" {
    description = "An Identifier to be used on all resources"
    type = string
    default = "eksDeploy"
}

variable "cidr" {
    description = "CIDR block to be used for EKS VPC"
    type = string
    default = "10.0.0.0/16"
  
}
variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = []
}

variable "region_subnet_prefix" {
    description = "A prefix to append to all region subnets"
    type = string
    default = "region"
}

variable "outpost_subnet_prefix" {
    description = "A prefix to append to all outposts subnets"
    type = string
    default = "outposts"
}

variable "region_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "region_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "outposts_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false 
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "tags" {
    description = "tags to be used for deploymet"
    type = map(string)
    default = {}  
}

variable "vpc_tags" {
    description = "tags to be used for the vpc"
    type = map(string)
    default = {}  
}

variable "map_public_ip_on_launch" {
    description = "determines if subnet has a public IP mapped on launch"
    type = bool
    default = true
  
}
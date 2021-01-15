provider "aws" {
  region = "us-west-2"
}

module "terraform-eks-outposts" {
  source = "../"
  azs    = ["us-west-2a", "us-west-2b", "us-west-2c"]
    # region_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  region_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  outposts_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
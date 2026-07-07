# Defining the provider
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block             = var.vpc_cidr_block
  public_subnet1_cidr_block  = var.public_subnet1_cidr_block
  public_subnet2_cidr_block  = var.public_subnet2_cidr_block
  private_subnet1_cidr_block = var.private_subnet1_cidr_block
  private_subnet2_cidr_block = var.private_subnet2_cidr_block
  public_subnet1_az          = var.public_subnet1_az
  public_subnet2_az          = var.public_subnet2_az
  private_subnet1_az         = var.private_subnet1_az
  private_subnet2_az         = var.private_subnet2_az
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "./modules/iam"

  role_name = var.instance_profile_role_name
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  dereg_delay       = var.dereg-delay
}

module "asg" {
  source = "./modules/asg"

  instance_type         = var.instance_type
  instance_profile_name = module.iam.instance_profile_name
  web_sg_id             = module.security_groups.web_sg_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  target_group_arn      = module.alb.target_group_arn
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
}

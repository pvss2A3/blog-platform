provider "aws" {
  region = var.region
}

module "vpc" {
  source    = "./modules/vpc"
  vpc_cidr  = var.vpc_cidr
  region    = var.region
}

module "rds" {
  source            = "./modules/rds"
  private_subnet_ids = module.vpc.private_subnet_ids
  db_sg_id          = module.vpc.db_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
}

module "ec2" {
  source           = "./modules/ec2"
  public_subnet_ids = module.vpc.public_subnet_ids
  app_sg_id        = module.vpc.app_sg_id
  rds_endpoint     = module.rds.db_endpoint
  db_password      = var.db_password
}

module "s3_cloudfront" {
  source = "./modules/s3_cloudfront"
  region = var.region
}
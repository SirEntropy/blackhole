provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = "${var.environment}-${var.org_base_name}"
  vpc_cidr     = var.vpc_cidr
  az_count     = var.az_count
  aws_region   = var.aws_region
}

module "ssm" {
  source       = "../../modules/ssm"
  project_name = "${var.environment}-${var.project_base_name}"
  environment  = var.environment
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "cased/comet"
}

module "alb" {
  source             = "../../modules/alb"
  project_name       = "${var.environment}-${var.project_base_name}"
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  health_check_path  = "/_healthz"
  domain_name        = "comet-staging.com"
  route53_zone_id    = "Z0694280MLUITF5HVWO"
  create_certificate = true
}

module "ecs" {
  source                = "../../modules/ecs"
  project_name          = "${var.environment}-${var.project_base_name}"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  app_port              = var.app_port
  app_count             = var.app_count
  fargate_cpu           = var.fargate_cpu
  fargate_memory        = var.fargate_memory
  ecr_repo_url          = module.ecr.repository_url
  aws_region            = var.aws_region
  alb_target_group_arn  = module.alb.target_group_arn
  alb_listener_http     = module.alb.alb_listener_http
  alb_listener_https    = module.alb.alb_listener_https
  alb_security_group_id = module.alb.alb_security_group_id
  ssm_parameter_arns    = module.ssm.ssm_parameter_arns
}

resource "random_string" "redis_username" {
  length  = 16
  special = false
}

resource "random_password" "redis_password" {
  length  = 32
  special = false
}

module "redis" {
  source                        = "../../modules/redis"
  project_name                  = "${var.environment}-${var.project_base_name}"
  vpc_id                        = module.vpc.vpc_id
  private_subnets               = module.vpc.private_subnets
  ecs_sg_id                     = module.ecs.ecs_tasks_sg_id
  redis_node_type               = "cache.t3.medium"
  redis_num_cache_nodes         = 2
  redis_snapshot_retention_limit = 1
  redis_engine_version          = "6.x"
  redis_parameter_group_family  = "redis6.x"
  redis_at_rest_encryption      = true
  redis_transit_encryption      = true
  redis_maintenance_window      = "sun:05:00-sun:06:00"
  redis_snapshot_window         = "01:00-02:00"
  redis_username                = random_string.redis_username.result
  redis_password                = random_password.redis_password.result
  redis_maxmemory_policy        = "allkeys-lru"
  redis_port                    = 6379
}

resource "random_string" "db_username" {
  length  = 24
  special = false
}

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "rds" {
  source               = "../../modules/rds"
  project_name         = "${var.environment}-${var.project_base_name}"
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  ecs_sg_id            = module.ecs.ecs_tasks_sg_id
  db_name              = var.db_name
  db_username          = random_string.db_username.result
  db_password          = random_password.db_password.result
  db_instance_class    = var.db_instance_class
  db_engine_version    = var.db_engine_version
  availability_zones   = ["us-west-2a", "us-west-2b"]  # Explicitly specify available AZs
  db_instance_count    = 2  # Make sure this matches the number of AZs
}

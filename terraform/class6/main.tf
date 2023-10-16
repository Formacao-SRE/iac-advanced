//Criar configuração do Provedor
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tf-elvenworks-iac-training"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
    workspace_key_prefix = "env:"
  }
}

//Chama o Módulo de Rede
module "network" {
    source = "git::https://gitlab.com/darkscreen/training/elvenworks/tf-modules/network.git"
    vpc_cidr = "10.255.0.0/16"
    vpc_name = "treinamento"
    cidr_privada1 = "10.255.1.0/24"
    cidr_privada2 = "10.255.2.0/24"
    cidr_publica1 = "10.255.3.0/24"
    cidr_publica2 = "10.255.4.0/24"
    nome_publica1 = "sub-publica1"
    nome_publica2 = "sub-publica2"
    nome_privada1 = "sub-privada1"
    nome_privada2 = "sub-privada-2"
    alb_sg_name = "wp-alb-sg"
    wp_alb_name = "wordpress-alb"
}

//Chama o Módulo de Web Server
module "wp-application" {
  source = "git::https://gitlab.com/darkscreen/training/elvenworks/tf-modules/wp-application.git"
  ec2_sg_name="webserver-sg"
  ec2_name="WebServer"
  key_pair_name = "lazevedo-elvenworks"
  vpc_id = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
  az = module.network.subnet_pub1_az
  subnet_id = module.network.subnet_pub1_id
  rds_password = var.rds_pass
  alb_arn = module.network.alb_arn
  db_subnets = [
    module.network.subnet_publica1,
    module.network.subnet_publica2
  ]
  depends_on = [
    module.network
  ]
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    working_dir = "/Users/lucas.azevedo/Documents/repos/darkscreen/elvenworks/iac/ansible/class6"
    command = "ansible-playbook -i inventory/aws_ec2.yaml wordpress.yaml"
  }
  depends_on = [
    module.network,
    module.wp-application
  ]
}

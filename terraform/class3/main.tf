//Criar configuração do Provedor
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tf-demo-iac-00"
    key    = "infra/network/terraform.tfstate"
    region = "us-east-1"
    workspace_key_prefix = "env:"
  }
}

//Chama o Módulo
module "network" {
    #source = "./modules/network"
    source = "git::https://gitlab.com/darkscreen/training/elvenworks/tf-modules/network.git"
    vpc_cidr = "10.255.0.0/16"
    vpc_name = var.vpc_name
    cidr_privada1 = "10.255.1.0/24"
    cidr_privada2 = "10.255.2.0/24"
    cidr_publica1 = "10.255.3.0/24"
    cidr_publica2 = "10.255.4.0/24"
    nome_publica1 = "sub-publica1"
    nome_publica2 = "sub-publica2"
    nome_privada1 = "sub-privada1"
    nome_privada2 = "sub-privada-2"
}




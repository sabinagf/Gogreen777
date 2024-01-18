module "bastion_security_group" {
  source  = "app.terraform.io/terraform_class990/security-groups/aws"
  version = "2.0.0"
  # insert required variables here
  vpc_id = aws_vpc.vpc.id
  security_groups = {
    "bastion_sg" : {
      description = "Security group for bastion host"
      ingress_rules = [
        {
          description = "ingress rule for ssh"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"] 
        }
      ]
      egress_rules = [
        {
          description = "needs to communicate to internet"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}

module "web_security_group" {
  source  = "app.terraform.io/terraform_class990/security-groups/aws"
  version = "2.0.0"
  # insert required variables here
  vpc_id = aws_vpc.vpc.id
  security_groups = {
    "web_sg" : {
      description = "web tier SG"
      ingress_rules = [
        {
          description = "http access"
          priority    = 200
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          # security_groups = [module._web_security_group.security_group_id["alb_web_sg"]]
        },
        {
          description = "https access"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "allows ssh"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          # cidr_blocks     = [join("", [aws_instance.bastion.private_ip, "/32"])]
          security_groups = [module.bastion_security_group.security_group_id["bastion_sg"]]
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}
module "_web_security_group" {
  source  = "app.terraform.io/terraform_class990/security-groups/aws"
  version = "2.0.0"
  # insert required variables here
  vpc_id = aws_vpc.vpc.id
  security_groups = {
    "alb_web_sg" : {
      description = "Security group for web load balancer"
      ingress_rules = [
        {
          description = "ingress rule for http"
          priority    = 220
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          #   
        },
        {
          description = "ingress rule for http"
          priority    = 204
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
      
        }
      ],
      egress_rules = [
        {
          description = "egress rule"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}


module "app_security_group" {
  source  = "app.terraform.io/terraform_class990/security-groups/aws"
  version = "2.0.0"
  # insert required variables here
  vpc_id = aws_vpc.vpc.id
  security_groups = {
    "app_sg" : {
      description = "APP sg"
      ingress_rules = [
        {
          priority        = 200
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          # cidr_blocks     = ["0.0.0.0/0"]
          security_groups = [module.web_security_group.security_group_id["web_sg"]]
        },
        {
          from_port = 22
          to_port   = 22
          protocol  = "tcp"
          # cidr_blocks     = [join("", [aws_instance.bastion.private_ip, "/32"])]
          security_groups = [module.bastion_security_group.security_group_id["bastion_sg"]]
        },

      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}
module "_app_security_group" {
  source  = "app.terraform.io/terraform_class990/security-groups/aws"
  version = "2.0.0"
  vpc_id  = aws_vpc.vpc.id
  security_groups = {
    "alb_app_sg" : {
      description = "Security group for app loadbalancer"
      ingress_rules = [
        {
          description     = "ingress rule for http"
          priority        = 240
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = [module.web_security_group.security_group_id["web_sg"]]
        }
      ],
      egress_rules = [
        {
          description = "egress rule"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}
module "database_security_group" {
  source  = "app.terraform.io/terraform_class990/security-groups/aws"
  version = "2.0.0"
  # insert required variables here
  vpc_id = aws_vpc.vpc.id
  security_groups = {
    "db_sg" : {
      description = "sg for db"
      ingress_rules = [
        {
          from_port       = 3306
          to_port         = 3306
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = [module.app_security_group.security_group_id["app_sg"]]
        },
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}



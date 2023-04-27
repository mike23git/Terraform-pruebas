data "aws_availability_zones" "available" {
  
}


resource "aws_vpc" "mtc_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  lifecycle {
    create_before_destroy = true
   }
  tags = {
    Name = "mtc_vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "id_gw"
  }
}

resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "mtc-public"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_default_route_table" "mtc_private_rt" {
  default_route_table_id = aws_vpc.mtc_vpc.default_route_table_id

  tags = {
    Name = "mtc_private"
  }
}


// Security Groups

resource "aws_security_group" "mtc_sg" {
  name = "public_sg"
  description = "Grupo de seguridad para las instancias publicas"
  vpc_id = aws_vpc.mtc_vpc.id
}
// Permite entrar a todos por todos los puertos
resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.access_ip]
  security_group_id = aws_security_group.mtc_sg.id
  description       = "Abrir puerto 22 para ssh"
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
}


resource "aws_security_group_rule" "egress_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mtc_sg.id
}



// Subnets no funciona
resource "aws_subnet" "mtc_public_subnet" {
  vpc_id = aws_vpc.mtc_vpc.id
  cidr_block = var.public_cidrs
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "mtc-public"
  }
}


// AMI de Ubuntu 
#resource "aws_instance" "web" {
#    ami = "ami-017d9f576d1635a77"
#    instance_type = "t2.micro"
#    security_groups = [module.sg.sg_name]
#    user_data = file("./web/server-script.sh")
#    tags = {
#        Name = var.ec2web
#    }
#}
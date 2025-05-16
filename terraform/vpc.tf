
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gateway"
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true 
  tags = {
    Name = "subnet_publica"
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "subnet_privada"
  }
}

resource "aws_route_table" "enrutamiento" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "enrutamiento publica"
  }
}

resource "aws_route_table_association" "asociacion_tablas" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.enrutamiento.id
}

resource "aws_eip" "ip_elastica" {
  domain = "vpc" 
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.ip_elastica.id     
  subnet_id     = aws_subnet.subnet_publica.id 
  depends_on    = [aws_internet_gateway.gateway] 
  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_route_table" "enrutamiento_privado" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"            
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "enrutamiento_privada"
  }
}

resource "aws_route_table_association" "asociacion_tablas_privada" {
  subnet_id      = aws_subnet.subnet_privada.id 
  route_table_id = aws_route_table.enrutamiento_privado.id
}


resource "aws_route53_zone" "privada53" {
  name = "contenedores.privado." 

  vpc {
    vpc_id = aws_vpc.vpc.id 
  }

}

resource "aws_route53_record" "ldap_dns" {
  zone_id = aws_route53_zone.privada53.zone_id 
  name    = "ldap"                           
  type    = "A"
  ttl     = 300
  records = [aws_instance.instancia_ldap.private_ip] 

}

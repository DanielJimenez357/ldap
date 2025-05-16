resource "aws_instance" "instancia_ldap" {
  ami                         = var.ami
  instance_type               = var.instancia
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.grupo_seguridad_ldap.id]
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet_privada.id

  
  user_data = file("${path.module}/configuracion_ldap.sh")

}

resource "aws_security_group" "grupo_seguridad_ldap" {

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 1389
    to_port         = 1389
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguridad_web.id] 
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.grupo_seguridad_web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



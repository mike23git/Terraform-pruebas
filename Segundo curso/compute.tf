data "aws_ami" "server_ami" {
  // Si tienes problemas con la empresa con la que trbajas poner la version actual :)
  most_recent = true
    
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

//SSH key

resource "aws_key_pair" "mtc_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}



resource "aws_instance" "mtc_main" {
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id = aws_subnet.mtc_public_subnet.id
  root_block_device {
    volume_size = var.main_vol_size
  }
  tags = {
    Name = "mtc-main"
  }
  // Esto crea en el archivo aws_host una linea con la ip publica
  provisioner "local-exec" {
    command = "printf '\n${self.public_ip}' >> aws_hosts"
  }
  //Esto elimina cuando se hace un destroy cualquier linea que tenga un numero
  provisioner "local-exec" {
    when = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts"
  }

}

output "instance_ips" {
    value = {for i in aws_instance.mtc_main[*] : i.tags.Name => "${i.public_ip}:3000"}
}

  

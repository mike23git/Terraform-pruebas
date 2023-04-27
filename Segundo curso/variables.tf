variable "vpc_cidr" {
  type = string
  default = "192.168.0.0/16"
}

variable "public_cidrs" {
  type = string
  default = "192.168.1.0/24"
}
// Aqui indico la ip por la que tiene acceso para entrar a la instancia
variable "access_ip" {
  type = string
  # default = "92.189.209.164/32"
  default = "0.0.0.0/0"
}

variable "main_instance_type" {
  type = string
  default = "t2.micro"
}

variable "main_vol_size" {
  type = number
  default = 8
  # Esto esta puesto en Gb
}


//keys SSH vairables que las coge de terraform.tfvars
variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

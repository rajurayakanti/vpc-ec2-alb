variable "cidr" {
  default = "10.0.0.0/16"

}

variable "subnet1" {
  default = "10.0.1.0/24"

}

variable "subnet2" {
  default = "10.0.2.0/24"

}

variable "ami" {
  default = "ami-09b0a86a2c84101e1"

}

locals "vpcname" {
  default ="myvpc"
}
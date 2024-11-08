resource "aws_vpc" "main" {
  cidr_block = var.cidr
  tags = {
    name = "local.vpcname"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet2
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

}

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
}

resource "aws_route_table_association" "PublicRT1a" {

  subnet_id = aws_subnet.sub1.id

  route_table_id = aws_route_table.RT.id

}

resource "aws_route_table_association" "PublicRT1b" {

  subnet_id = aws_subnet.sub2.id

  route_table_id = aws_route_table.RT.id

}

resource "aws_security_group" "my_security_group1" {
  vpc_id      = aws_vpc.main.id
  name        = "group1"
  description = "Security group for SSH, HTTP, and RDP access"

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["106.212.237.117/32"] # Allow RDP only from your IP
  }

  # Outbound rule (allow all egress traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_security_group"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "my-terraformmm-qa"

}

resource "aws_instance" "webserver1" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_security_group1.id]
  iam_instance_profile   = aws_iam_instance_profile.admin_instance_profile.name
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))

}

/*resource "aws_instance" "webserver2" {

  ami                    = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_security_group1.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))

}


#create alb
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.my_security_group1.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
*/

resource "aws_iam_instance_profile" "admin_instance_profile" {
  name = "admin_instance_profile"
  role = "admin_Role" # Attach the existing IAM role here
}


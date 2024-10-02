
#Step 1 : Create a VPC 

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true  # Enable IPv6 for this VPC
  tags = {
    Name = "project-vpc"
  }
}

#Step  2 : Create an Internet Gateway

resource "aws_internet_gateway" "prod-gateway" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "project-internet-gateway"
  }
}

#Step 3: Create a Custom Route Table

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.prod-gateway.id
  }

  tags = {
    Name = "project-route-table"
  }
}

#Step 4 : Create a Subnet

resource "aws_subnet" "subnet-2" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"


    tags = {
    Name = "project-subnet-1"
  }

}

#Step 5 : Associate Subnet with Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.prod-route-table.id
}

#Step 6 : Create a Security Group to allow port 22, 80 and 443

resource "aws_security_group" "allow_tls" {
  name        = "allow-web-traffic"
  description = "Allow Web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  tags = {
    Name = "allow-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4-1" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.prod-vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6-1" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.prod-vpc.ipv6_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4-2" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.prod-vpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6-2" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.prod-vpc.ipv6_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4-3" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.prod-vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6-3" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.prod-vpc.ipv6_cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#Step 7 : Create a Network Interface with an IP in the subnet that was created in Step 4

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-2.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_tls.id]

}

#Step 8 : Assign an Elastic IP to the interface created in Step 7

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_network_interface.web-server-nic]
}

#Step 9 : Create an Ubuntu Server and Install/Enable Apache2

resource "aws_instance" "web-server-instance" {
    ami = "ami-0e86e20dae9224db8"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "project-access-key"
    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id

    }
user_data = <<-EOF

                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c "echo your very first web server > /var/www/html/index.html"
                EOF

        tags = {
            Name = "web-server"
        }
}

# Fixing the ipv6 issues: 
resource "aws_egress_only_internet_gateway" "ipv6_eigw" {
  vpc_id = aws_vpc.prod-vpc.id
}

resource "aws_route" "ipv6_route" {
  route_table_id         = aws_route_table.prod-route-table.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id  = aws_egress_only_internet_gateway.ipv6_eigw.id
}


resource "aws_security_group_rule" "allow_tls_ipv6" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = [aws_vpc.prod-vpc.ipv6_cidr_block]  # Wrap in square brackets as it's a list
  security_group_id = aws_security_group.allow_tls.id
}



# Crear VPC
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames =true

  tags = {
    Name = "mainvpc"
  }
}

# Crear 1 subred publica y dos privadas

resource "aws_subnet" "PublicSub1" {
    vpc_id = "${aws_vpc.myVPC.id}"
    cidr_block = "10.0.128.0/20"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
      tags = {
    Name = "Subnet publica 1 zona US EAST 1A"
  }
}

resource "aws_subnet" "PrivateSub1" {
    vpc_id = "${aws_vpc.myVPC.id}"
    cidr_block = "10.0.0.0/19"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
      tags = {
    Name = "Subnet privada1 zona US EAST 1A"
  }
}

resource "aws_subnet" "PrivateSub2" {
    vpc_id = "${aws_vpc.myVPC.id}"
    cidr_block = "10.0.192.0/21"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
      tags = {
    Name = "Subnet privada2 zona US EAST 1A"
  }
}

# Crear un GW  de internet 
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.myVPC.id}"
    tags = {
    Name = "Gateway_Internet"
  }
}

#Crear un tabla de rutas y asociarla a las subredes 

resource "aws_route_table" "route1"{
    vpc_id = "${aws_vpc.myVPC.id}"
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id ="${aws_internet_gateway.gw.id}"
    }
}

resource "aws_route_table" "PrivateRouteTable" { 
  vpc_id = "${aws_vpc.myVPC.id}"
  tags = {
    Name = "PrivateRouteTable" 
  } 
  depends_on = [aws_vpc.myVPC]
}

resource "aws_route_table_association" "table_subnet1"{
  subnet_id = "${aws_subnet.PublicSub1.id}"
  route_table_id = "${aws_route_table.route1.id}"
}
resource "aws_route_table_association" "table_subnet2"{
  subnet_id = "${aws_subnet.PrivateSub1.id}"
  route_table_id = "${aws_route_table.PrivateRouteTable.id}"
}
resource "aws_route_table_association" "table_subnet3"{
  subnet_id = "${aws_subnet.PrivateSub2.id}"
  route_table_id = "${aws_route_table.PrivateRouteTable.id}"
}


# route53 ********
resource "aws_route53_zone" "VPCPROD"{
  name = "vpcprod.com"
  force_destroy = false
  vpc {
  vpc_id = "${aws_vpc.myVPC.id}"
  }
}

resource "aws_route53_record" "server1" {
  zone_id = "${aws_route53_zone.VPCPROD.zone_id}"
  name    = "publicaserver1.vpcprod.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.PublicEC2_1.private_ip}"]
}

# ELASTIC LOAD BALANCING ******

resource "aws_elb" "Balanceador" { 
    name = "myloadbalancer"
    subnets = ["${aws_subnet.PublicSub1.id}"]
listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
}

listener {
    instance_port     = 443
    instance_protocol = "https"
    lb_port           = 443
    lb_protocol       = "http"
    #ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
}

health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.PublicEC2_1.id}","${aws_instance.PublicEC2_3.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }


}
 # ELASTIC IP ******
 resource "aws_eip" "eip_1"{
    instance = "${aws_instance.PublicEC2_1.id}"
    vpc = true
      tags = {
    Name = "eip_server1"
  }

 }

  resource "aws_eip" "eip_2"{
    instance = "${aws_instance.PublicEC2_3.id}"
    vpc = true
      tags = {
    Name = "eip_server1"
  }

 }
 
resource "aws_instance" "sonarqube" {
  ami                         = "ami-03f4878755434977f" # Ubuntu 22.04 ap-south-1
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_az1.id
  vpc_security_group_ids      = [aws_security_group.sonarqube.id]
  iam_instance_profile        = aws_iam_instance_profile.sonarqube.name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-17-jdk unzip postgresql
              systemctl enable postgresql
              systemctl start postgresql
              EOF

  tags = {
    Name = "${local.env}-sonarqube"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.env}-public-rt"
  }
}
resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

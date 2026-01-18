resource "aws_security_group" "jenkins" {
  name        = "${local.env}-jenkins-sg"
  description = "Jenkins Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # demo only
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["194.9.78.40/32"] # replace later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env}-jenkins-sg"
  }
}

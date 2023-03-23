
provider "aws" {
 access_key = "AKIA3NGRVEZELPPBAM6Q"
 secret_key = "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"
  region = "us-east-1"

}



resource "aws_security_group" "webserver_sg" {
  name_prefix = "webserver_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver" {
  ami           = "ami-02f3f602d23f1659d"
  instance_type = "t2.micro"
   key_name      = "sample"

  tags = {
    Name = "Webserver"
  }

  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    # Download and extract airgap package
    mkdir /usr/share/nginx/html/airgap
    curl https://download.docker.com/linux/static/stable/x86_64/docker-18.09.9.tgz -o /usr/share/nginx/html/airgap/docker-18.09.9.tgz
    tar -xvf /usr/share/nginx/html/airgap/docker-18.09.9.tgz -C /usr/share/nginx/html/airgap/
    rm /usr/share/nginx/html/airgap/docker-18.09.9.tgz
    
    # Configure Nginx to serve airgap package
    cat <<EOF2 > /etc/nginx/conf.d/airgap.conf
    server {
      listen 80;
      server_name _;
    
      location /airgap {
        alias /usr/share/nginx/html/airgap/;
        autoindex on;
      }
    }
    EOF2
    
    sudo systemctl restart nginx
  EOF
}


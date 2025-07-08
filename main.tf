resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx unzip wget -y
              cd /var/www/html
              wget ${var.website_zip_url}
              unzip 2135_mini_finance.zip
              rm -f index.nginx-debian.html
              cp -r 2135_mini_finance/* .
              rm -rf 2135_mini_finance 2135_mini_finance.zip
              systemctl restart nginx
              EOF

  tags = {
    Name = "Tooplate-Mini-Finance"
  }
}

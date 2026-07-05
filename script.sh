     
      #!bin/bash
      sudo yum update -y
      sudo yum install httpd -y
      sudo systemctl start httpd.service
      sudo systemctl enable httpd
      sudo echo "This is an web/app tier server " > /var/www/html/index.html

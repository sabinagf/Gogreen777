 #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd.service
              sudo systemctl enable httpd.service
              sudo echo "<h1> HELLO from ${each.value.server_name} </h1>" > /var/www/html/index.html

#!/bin/bash

# sleep until instance is ready - warm up
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install apache
yum update -y
yum install htop -y
yum install httpd -y
yum install vim -y
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
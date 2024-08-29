#!/bin/bash

# Add the proxy configuration
touch /etc/apt/apt.conf.d/00proxy
echo "Acquire::http::Proxy "http://10.0.3.233:3128";" | sudo tee -a /etc/apt/apt.conf.d/00proxy
echo "Acquire::https::Proxy "http://10.0.3.233:3128";" | sudo tee -a /etc/apt/apt.conf.d/00proxy

# Install the apache server
apt-get update -y
apt-get install -y apache2
systemctl start apache2
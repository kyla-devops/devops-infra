#!/bin/bash
apt-get update -y && apt-get upgrade -y
apt-get install -y squid
systemctl start squid
# Add ACL and allow rules to squid.conf
echo "acl localnet1 src 10.0.2.123/32" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet2 src 10.0.1.79/32" | sudo tee -a /etc/squid/squid.conf
echo "http_access allow localnet1" | sudo tee -a /etc/squid/squid.conf
echo "http_access allow localnet2" | sudo tee -a /etc/squid/squid.conf
echo "http_access allow all" | sudo tee -a /etc/squid/squid.conf
# echo "acl frontend_server dstdomain 65.2.166.127" | sudo tee -a /etc/squid/squid.conf
# echo "cache_peer 10.0.2.123 parent 80 0 no-query originserver name=frontend1" | sudo tee -a /etc/squid/squid.conf
# echo "cache_peer 10.0.1.79 parent 80 0 no-query originserver name=frontend2" | sudo tee -a /etc/squid/squid.conf
# echo "http_port 80" | sudo tee -a /etc/squid/squid.conf
# echo "acl http proto HTTP" | sudo tee -a /etc/squid/squid.conf
# echo "http_access allow http frontend_server" | sudo tee -a /etc/squid/squid.conf
# echo "http_access allow frontend_server" | sudo tee -a /etc/squid/squid.conf
# echo "http_access allow http" | sudo tee -a /etc/squid/squid.conf
# echo "cache_peer_access frontend1 allow frontend_server" | sudo tee -a /etc/squid/squid.conf
systemctl restart squid
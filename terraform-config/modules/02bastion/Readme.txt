This module should be run after 01vpc.
Here we are creation a bastion host as public ec2 instance which we will use to connect to our private ec2s and make it work as proxy and reverse-proxy server for the same private-ec2s.

Once the bastion EC2 is running, we have to install forward-proxy (squid) and reverse-proxy (nginx).

Follow the below steps to configure forward-proxy (squid):
1. Login to the bastion instance using command: ssh -i "PATH_TO_PEM_FILE" ubuntu@BASTION_PUBLIC_IP
2. Run the command to install squid proxy: sudo apt-get update, sudo apt-get install squid
3. Edit the squid proxy configuration to accept traffic from private-ec2s private-ips: sudo vi /etc/squid/squid.conf
    acl localnet1 src 10.0.2.123/32  #Private-EC2-0 Private IP
    acl localnet2 src 10.0.1.79/32  #Private-EC2-1 Private IP
    http_access allow localnet1
    http_access allow localnet2
    Save the file.
4. Restart the proxy server: sudo systemctl restart squid

The configurations to be done for forward-proxy in Private-EC2 is added in Readme.txt of 03ec2 block.

Follow the below steps to configure reverse-proxy (nginx):
1. Login to the bastion instance using command: ssh -i "PATH_TO_PEM_FILE" ubuntu@BASTION_PUBLIC_IP
2. Run the command to install nginx server: sudo apt-get install nginx
3. Update the nginx proxy configuration to forward the http traffic from internet to private-ec2s:
    Edit the nginx configuration to add upstream block: sudo vi /etc/nginx/nginx.conf
        Add the below in existing http block:
        upstream backend {
                server 10.0.2.123:80; #Private-EC2-0 Private IP
                server 10.0.1.79:80; #Private-EC2-1 Private IP
        }
        Save the file.
    Remove the default sites configuration: sudo rm /etc/nginx/sites-available/default
    Create the same file to add new configuration: vi /etc/nginx/sites-available/default
    Add the below data:
        server {
            listen 80;
            location / {
                proxy_pass http://backend; # backend is defined as upstream block which was added above.
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }
        }
4. Restart the proxy server: sudo systemctl restart nginx
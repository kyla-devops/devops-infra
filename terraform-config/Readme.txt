Tasks to do if new private EC2 instances are created:

1. Update VPC with private IPs.

2. Update ssh config.
    Update bastion public IP
    Update private-ec2s IPs

3. Bastion-update Squid and Nginx.
    sudo vi /etc/squid/squid.conf
    sudo systemctl restart squid
    sudo vi /etc/nginx/nginx.conf
    sudo systemctl restart nginx

4. Add AcquireProxy to New EC2s.
    sudo nano /etc/apt/apt.conf.d/00proxy
    Acquire::http::Proxy "http://10.0.3.233:3128";
    Acquire::https::Proxy "http://10.0.3.233:3128";

5. Add key.pub to private-ec2s.
    cat ~/.ssh/key.pub
    Connect to private-ec2
    vi ~/.ssh/authorized_keys
    Paste the key

6. Validate Forward-Proxy.
    Connect to private-ec2 and run:
    sudo apt-get update

7. Validate Reverse-Proxy.
    Connect to private-ec2 and run:
    sudo apt-get install apache2
    Copy bastion's public IP and access on internet with http to load apache server homepage.
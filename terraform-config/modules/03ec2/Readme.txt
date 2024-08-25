We can run this module to create public & private EC2 instances in all the subnets/availabilty-zones that VPC got created in.
The key-pair used in instances is created from AWS Console as terraform does not support direct download/creation of pem files to be used while login.

Here we are creating 2 private ec2 instances.
Once these instances are created, we have to get the private-ips of both instances and pass it in the security-group of bastion so we can connect to these instances via ssh.

Also, to download any package, we have setup squid-proxy in bastion-host. So once the ec2 instance is running, we have to execute the following in the instance to be able to download packages.
1. Setup proxy variables like (export http_proxy=http://<bastion-private-ip>:3128, export https_proxy=http://<bastion-private-ip>:3128) ==> these command will allow us to send curl requests to the internet.
2. Create Proxy Configuration for Package Downloading (execute the below steps):
   a. sudo nano /etc/apt/apt.conf.d/99proxy
   b. Add data:
        Acquire::http::Proxy "http://<bastion-private-ip>:3128";
        Acquire::https::Proxy "http://<bastion-private-ip>:3128";
   c. Save the file.
   d. Run "apt-get update" to validate.

Steps to connect to private-ec2 via ssh:
1. User should have the key-pair pem file downloaded on local system.
2. Give necessary permissions to the file downloaded: chmod 400 PATH_TO_FILE/FILENAME.pem
3. Use the command to connect to bastion host: ssh -i "PATH_TO_FILE/FILENAME.pem" ubuntu@<bastion-public-ip>
4. Create a new file and paste to add same key-pair on bastion host: vi FILENAME.pem
5. Connect to private-ec2 via ssh: ssh -i "FILENAME.pem" ubuntu@<private-ec2-private-ip>
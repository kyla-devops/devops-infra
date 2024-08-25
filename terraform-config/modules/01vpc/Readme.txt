VPC module is to be run with devops-user which is created as part of 00user-creation terraform setup.
Profile is added in provider.tf configuration.

Here we are creating the following:
1. VPC.
2. Two Private Subnets which will attach with private-ec2 (using 2 so for future development, we will have 2 instances and when we install kubernetes 1 will work as master and other as slave).
3. One Public Subnet which will attach with bastion host which will be used as jumphost, proxy and reverse-proxy for private ec2s.
4. Internet Gateway to direct traffic to internet (added to subnet for bastion).
5. One Public Security Group defining rules (ingress for cidrs of 2 users to be able to connect via ssh, ingress for http from public to allow FE application to be accessible, ingress to allow private ec2 traffic and allowing all outbound traffic via egress).
6. One Private Security Group defining rules (ingress to allow bastion ec2 traffic and allowing all outbound traffic via egress).
7. One Public Route Table to attach Internet Gateway and associate route table with public subnet.

NOTE:
The Public and Private Security Groups have the IPs of Bastion and Private-EC2s hardcoded because if we use data-block to fetch the IPs, the instance must be running.
In this case, we need not to run the instance and VPC module can be run without dependencies.
If we destroy and create new instances of bastion or private-ec2s rather than just stopping and starting, we have to update the IPs in security group manually.

Steps:
1. Run the 01vpc module.
2. Run the 02bastion module.
3. Run the 03ec2 module.
4. Get the private-ips of private-ec2s created and public,private-ip of bastion and update the security group blocks.
5. Reapply the 01vpc module.
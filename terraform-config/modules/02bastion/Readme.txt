This module should be run after 01vpc.
Here we are creation a bastion host as public ec2 instance which we will use to connect to our private ec2s and make it work as proxy and reverse-proxy server for the same private-ec2s.

Once the bastion EC2 is running, we have to install proxy. The user-data block is added to install squid proxy and configure the private-ec2s IPs.

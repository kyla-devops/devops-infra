We can run this module to create public & private EC2 instances in all the subnets/availabilty-zones that VPC got created in.
The key-pair used in instances is created from AWS Console as terraform does not support direct download/creation of pem files to be used while login.

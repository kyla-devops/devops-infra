02nat block is to be run if we want to directly allow private-ec2s to connect to internet via internet-gateway.
Here we create an EIP which will be used in Nat-gateway creation which gets created under a public subnet.
Then we create a route-table to attach the NAT-Gateway and associate it with private ec2s.

So, when we request any dependency from private-ec2, it will forward the request to NAT-Gateway which will in turn go through Internet-gateway to fetch the dependency.
We will not use NAT-Gateway block because of below reasons:
1. It incurs a cost (hourly + based on usage).
2. Needs an EIP which also incurs a cost (hourly).
3. Does not resolve the issue of exposing application to the internet.

In place of this, we are creating a bastion-host which will allow us to connect to the private-ec2, serve as a proxy-server to download packages and reverse-proxy server to expose application to the internet.

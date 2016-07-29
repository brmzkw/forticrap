Forticrap
=========

Runs easily the [Fortigate](https://www.fortinet.com/products/fortigate/) SSL
VPN client in a Docker container.



REQUIREMENTS
============

Docker must be installed. I tested my installation on OSX with
[docker-machine](https://docs.docker.com/machine/install-machine/), but
everything should work fine on Linux too.


HOWTO
=====

Build the configuration file:

`$> make config`

Edit the file `~/.forticrap` with your VPN credentials.

Build and run the Docker container:

`$> make`


Now, we need to redirect the traffic to the Docker container. Imagine we want
to reach the IP `10.230.0.140` which is only accessible through the VPN.


**On OSX**

You need ot add a route to forward traffic destinated to `10.230.0.140` to the
docker host:

`$> sudo route -n add -net 10.230.0.140 $(docker-machine ip)`

Now, SSH on the Docker host:

`$> docker machine ssh`

Let's forward the traffic to `10.230.0.140` to the Docker container:

`(docker host)> sudo ip route add 10.230.0.140 via 172.20.0.2`

*NOTE*: `172.20.0.2` is hardcoded in the [Makefile](./Makefile). You can get this
IP address with `docker inspect forticrap | grep IPAddress'.

And do the iptables magic to route packets:

`(docker host)> iptables -t nat -A POSTROUTING -s $(ip a | grep eth1 | grep inet | awk '{print $2}') -j MASQUERADE`


**On Linux**

Running  `(docker host)> sudo ip route add 10.230.0.140 via $(docker inspect -f '{{.NetworkSettings.Networks.bridge.IPAddress}}' forticrap)` should be okay, but I didn't test.


NOTES
=====

`--privileged` is required to create the `ppp` VPN interface.

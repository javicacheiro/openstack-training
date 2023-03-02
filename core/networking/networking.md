# Networking in OpenStack
Software Defined Networking (SDN) using OVN.

Types of networks:
- **Provider network**: datacenter networks
- **External network**: a special type of provider network
- **Tenant network**: self-service, isolate traffic between tenants/projects

Notes:
- Provider networks are pre-created by the administrators: eg. provnet-formacion-vlan-133
- External networks are provider networks that have an extra flag that allows virtual routers to connect.
- Tenant networks allow the creation of a **Virtual Private Cloud (VPC)**.


Type of network | Who can create it | External router
----------------+-------------------+----------------
Provider        | Admin             | Not managed by openstack
External        | Admin             | Managed by openstack
Tenant          | User              | Managed by openstack

## Provider and external networks
Access to provider networks has to be requested so that an admin can give our project access to them.

They operate outside of openstack SDN and they have their our network infrastructure and routers.

Our projects have access to a external network called `public-default` that we can use this external network to connect our routers to it.

## Tenant networks
These are the networks that we can create on our own so that we can deploy a VPC.

The traffic is isolated from other tenant networks (SDN).

## CLI
List networks:
```
openstack network list
```

List routers:
```
openstack router list
```

List subnets:
```
openstack subnet list
```

Show information about a given subnet:
```
openstack subnet show subnet-formacion-vlan-133
```

## Creating a tenant network
In horizon go to network topology and create a new network (you can also do it from networks).

In the CLI we can creating a tenant network using:
```bash
EXTERNAL_ROUTER=router-external
NET_NAME=net_course_1
SUBNET_NAME=subnet_course_1
openstack network create --mtu 1500 ${NET_NAME}
openstack subnet create ${SUBNET_NAME} --network ${NET_NAME} --subnet-range 192.168.200.0/24 --dns-nameserver 193.144.34.209
```

## Give access to the internet to the tenant network
If you do not see the `router-external` then you have to create your own router (this consumes a public IP from the `public-default` network).

First you have to create a router, you can do it from network topology (or from the router the menu).

You have to go to network topology and add a port to the gateway with the tenant network.

From the CLI:
```
EXTERNAL_ROUTER=router-external
SUBNET_NAME=subnet_course_1
openstack router add subnet ${EXTERNAL_ROUTER} ${SUBNET_NAME}
```

## Assign a specific IP
```
openstack server create --nic net-id=private,v4-fixed-ip=192.168.1.123 --flavor m1.micro --image cirros a
```

## Forwarding traffic to the internal nodes
Use case:
- VM1: 192.168.200.100 and floating IP
- VM2: 192.168.200.2
- VM3: 192.168.200.3

We want to connect through ssh to VM2 and VM3 from the floating ip of VM1 using ports 1001 and 1002:
```
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p tcp --dport 1001 -j DNAT --to-destination 192.168.200.107:22
iptables -t nat -A PREROUTING -p tcp --dport 1002 -j DNAT --to-destination 192.168.200.86:22
iptables -t nat -A POSTROUTING -j MASQUERADE
```

Now we can connect to VM2 using:
```
ssh -p 1002 cesgaxuser@<floating_ip_vm1>
```
## Assign a fixed IP
To assign a fixed ip we can use the --nic option:
```
openstack server create --nic net-id=net-uuid,v4-fixed-ip=ip-addr ...
```

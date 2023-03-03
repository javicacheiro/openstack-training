# Networking in OpenStack
OpenStack makes use of Software Defined Networking (SDN) using OVN.

Types of networks:
- **Provider network**: datacenter networks
- **External network**: a special type of provider network
- **Tenant network**: self-service, isolate traffic between tenants/projects

Notes:
- Provider networks are pre-created by the administrators: eg. provnet-formacion-vlan-133
- External networks are provider networks that have an extra flag that allows virtual routers to connect to them in order to add external connectity.
- Tenant networks allow the creation of a **Virtual Private Cloud (VPC)**.


| Type of network | Who can create it | External router |
| ----------------+-------------------+---------------- |
| Provider        | Admin             | Not managed by openstack |
| External        | Admin             | Allows a router to have external access |
| Tenant          | User              | Managed by openstack |

## Provider and external networks
Access to provider networks has to be requested so that an admin can give our project access to them.

They operate outside of openstack SDN and they have their our network infrastructure and routers.

Our projects have access to a external network called `public-default` that we can use this external network to connect our routers to it.

## Tenant networks
These are the networks that we can create on our own so that we can deploy a VPC.

The traffic is isolated from other tenant networks (SDN).

### Creating a tenant network
We can create a tenant network in the `Network > Network Topology` with the "Create Network" button:

![network](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-tenant-network-1.png?raw=true)
![network](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-tenant-network-2.png?raw=true)
![network](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-tenant-network-3.png?raw=true)
![network](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-tenant-network-4.png?raw=true)
![network](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-tenant-network-5.png?raw=true)

At this point **this will be a private network with the traffic completely isolated from any other networks**.

Specifically, the instances running in this network will be isolated at Level 2 from instances running in other networks.

## Creating a router
To give access to the internet to the tenant network we will need a router.

The projects usually have already a tenant network that we created for them and this tenant network already has external access through a router named `router-external`.

If you see the `router-external` in your project you can use it to give external access to your new tenant networks.

If you do not see the `router-external` then you have to create your own router. Take into account that **this will consume a public IP from the `public-default` network**.

To create the router we can do it from network topology and remember to set `public-default` in the "External Network" option:

![router](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-router-1.png?raw=true)
![router](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-router-2.png?raw=true)
![router](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-router-3.png?raw=true)

Once the router has been created, we see that it is already connected with the `public-default` network but we still have to connect our tenant network to it. For that move the mouse over the router and select "Add Interface":

![connect-to-router](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-connect-network-to-router-1.png?raw=true)
![connect-to-router](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-connect-network-to-router-2.png?raw=true)
![connect-to-router](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-connect-network-to-router-3.png?raw=true)

We can now launch an instance and select this network:
![instance-net-course-1](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-instance-net-course-1.png?raw=true)
![instance-net-course-1](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-instance-net-course-2.png?raw=true)

## Associating a floating IP
We will not be able to connect to the instances in our private tenant network unless we assocate a floating IP to the instance. This is a public IP that will be associated to this instance and that will allow us to connect to it.

![floating-ip](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-associate-floating-ip-1.png?raw=true)
![floating-ip](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-associate-floating-ip-2.png?raw=true)
![floating-ip](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-associate-floating-ip-3.png?raw=true)
![floating-ip](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-associate-floating-ip-4.png?raw=true)
![floating-ip](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-associate-floating-ip-5.png?raw=true)

Now you will able to access the instance using this public IP.

NOTE: It is only possible to associate floating ips to instances that are in tenant networks with external access (ie. connected to a router with external access).

IMPORTANT: Before associating a floating IP to a instance it is critical to verify the Security Group of the instance.

## Associating a fixed IP (port creation)
We can assign a fixed IP to a instance by previously creating a port. Then we can associate this port to any instance that we want, in a similar way to a floating IP.

To create a port go to the `Network > Networks` view and click on the name of the network where you want to create the port:

![create-port](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-port-1.png?raw=true)
![create-port](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-port-2.png?raw=true)
![create-port](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-port-3.png?raw=true)
![create-port](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-port-4.png?raw=true)

Then when launching a new instance we will be able to associate this port to it:
![associate-port](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-associate-port-1.png?raw=true)
![associate-port](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-associate-port-2.png?raw=true)

## Forwarding traffic to the internal nodes
Connecting to an instance in the tenant network that has a floating ip we can jump to all the other instances in the tenant network, but sometimes this is cumbersome.

One simple option to enable access to other instances it is to use iptables in the instance with the floating IP.

Let's consider this scenario:
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

## Deleting a tenant network and the associated router
Follow this steps in the "Network Topology" view:
- Verify no instances are connected to this network: ie. there are no instance icons connected to this network
- Delete the router interfaces
- Delete the router
- Delete the network

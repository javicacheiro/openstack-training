# Openstack SDK
There are several OpenStack SDKs for different languages like Go, Java, Javacript, .NET, php, Pyhton, Ruby, Perl, C or C++.
- [OpenStack SDKs](https://wiki.openstack.org/wiki/SDKs)

We will focus in the official Python SDK called `openstacksdk`.

## Installation
The Python SDK is already included when we install the `openstack-cli`.

## Configuration
We will create a yaml file called `clouds.yaml`:
```
clouds:
 cesga:
   region_name: RegionOne
   auth:
     auth_url: 'https://cloud.srv.cesga.es:5000'
     username: xxxx
     password: xxxx
     user_domain_name: xxxx
     project_name: xxxx
     project_domain_name: xxxx
```

In the file we can include more than one OpenStack cloud, for that reason the file is called clouds.

openstacksdk will look for this file in the following locations:
- in the current directory
- $HOME/.config/openstack
- /etc/openstack

You can also set the location with the environment variable `OS_CLIENT_CONFIG_FILE`.

## Using it
The `openstacksdk` API consists of three layers:
- The *cloud* layer: provides highe-level abstractions for the logical operations
- The *proxy layer*: acts as a proxy to each of individual OpenStack components: compute (Nova), image (Glance), volume (Cinder), network (Neutron), etc.
- The *resource layer*: the low-level API that provides support for the CRUD operations supported by each resource of the REST API. It is used by the other layers. Typically you will not use it.

Most users will make use of the proxy layer.
```python
import openstack
conn = openstack.connect(cloud='cesga')

#
# Layer 1: cloud layer
#

# List servers
servers = conn.list_servers()

# List images
images = conn.list_images()

# List flavors
flavors = conn.list_flavors()

# List networks
networks = conn.list_networks()

# Upload an image
image = conn.create_image('cirros', filename='../cirros-0.6.1-x86_64-disk.raw', wait=True)

# Find a flavor with at least 2GB of RAM
flavor = conn.get_flavor_by_ram(2*1024)
print(flavor.name)

# Create a server and  associate a floating-ip to it (wait to it)
conn.create_server('test-server-public', image=image, flavor=flavor, auto_ip=True, wait=True)

# By default the auto_ip is set to True so if we do not want to associate a floating-ip we have to set auto_ip to False
conn.create_server('test-server', image=image, flavor=flavor, network='provnet-formacion-vlan-133', auto_ip=False, wait=True)

# Get a given network
network = conn.get_network('provnet-formacion-vlan-133')
print(network.mtu)

#
# Layer 2: proxy layer
#
# List servers
servers = conn.compute.servers()

# List images
images = conn.image.images()

# To print the info we use the to_dict() method
for server in servers:
    print(server.to_dict())

for image in images:
    print(image.to_dict())

# Create a server
image = conn.compute.find_image(IMAGE_NAME)
flavor = conn.compute.find_flavor(FLAVOR_NAME)
network = conn.network.find_network(NETWORK_NAME)
keypair = conn.compute.find_keypair(KEYPAIR_NAME)

server = conn.compute.create_server(
    name=SERVER_NAME, image_id=image.id, flavor_id=flavor.id,
    networks=[{"uuid": network.id}], key_name=keypair.name)

server = conn.compute.wait_for_server(server)

address = server.access_ipv4

#
# Layer 3: resource layer
#
# List servers
servers = openstack.compute.v2.server.Server.list(session=conn.compute)

# List images
images = openstack.image.v2.image.Image.list(session=conn.compute)

# To print the info we use the to_dict() method
for server in servers:
    print(server.to_dict())

for image in images:
    print(image.to_dict())
```

## References
- [openstacksdk official documentation](https://docs.openstack.org/openstacksdk/xena/user/guides/intro.html)
- [openstacksdk github repo](https://github.com/openstack/openstacksdk)

## Lab
- [Exporting openstack instance list in /etc/hosts format](labs/exporting_hosts.md)

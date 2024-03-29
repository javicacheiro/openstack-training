# Openstack-CLI

## Installing openstack-cli
First we need to install the CLI tools. We will do it in the following lab:
- [Installing openstack-cli lab](labs/installing_openstack-cli.md)

## OpenStack RC File
To use the `openstack-cli` we have to use a configuration file that provides the details about the OpenStack installation. This is called the `OpenStack RC File`.

The easiest way to get the `OpenStack RC File` is to connect to the Horizon web interface and under our username select `OpenStack RC File`. This will download our `OpenStack RC File` and then we can upload it to our `openstack-cli` instance.

Before using the `openstack-cli` we will have to load it with:
```bash
source username-openrc.sh
```

## CLI
The `openstack-cli` provides a way to interact with the OpenStack REST API.

For example to list available images we will use:
```
openstack image list
```

The structure of the commands is always the same.

We can use `TAB` to auto-complete commands and show options.

### CLI generic options
There are some generic options that we can always use:

Show help:
```
# using -h or --help option
openstack image list -h
# using help command
openstack help image list
```

Formatting output:
```
-f {json,shell,table,value,yaml}
-c COLUMN
--sort-column SORT_COLUMN
--sort-ascending | --sort-descending
```

Examples:
```
[cesgaxuser@openstack-cli ~]$ openstack image list
+--------------------------------------+------------------------------+--------+
| ID                                   | Name                         | Status |
+--------------------------------------+------------------------------+--------+
| 52a004ff-2a0f-42da-b93c-bbc1b366fc9c | baseos-AlmaLinux-8.4-v3      | active |
| b39960c4-1f13-408f-8266-2fbf17079539 | baseos-CentOS8-stream-v3     | active |
| bc5c4a50-e2e3-42a7-ae5f-214487a6cba4 | baseos-CentOS9-stream-v2     | active |
| ee29fab1-25b2-4bde-8d7b-538976846c84 | baseos-Debian-10-v2          | active |
| 771433be-311f-4f9c-af82-060fb692c506 | baseos-Debian-11-v1          | active |
| 61450471-1d15-48ca-af2a-8476cd54b7d8 | baseos-Rocky-8.5-v2          | active |
| 358ca60a-e5c8-41c3-b9f5-400bb67f179d | baseos-Ubuntu-20.04-v5       | active |
| 12e94670-f453-462f-99cb-d9e344d90248 | baseos-Ubuntu-22.04-v2       | active |
| ffb90109-7bd4-43c3-87fc-a56e2e4058c0 | baseos-openSUSE-Leap-15.3-v2 | active |
+--------------------------------------+------------------------------+--------+

[cesgaxuser@openstack-cli ~]$ openstack image list -f value
52a004ff-2a0f-42da-b93c-bbc1b366fc9c baseos-AlmaLinux-8.4-v3 active
b39960c4-1f13-408f-8266-2fbf17079539 baseos-CentOS8-stream-v3 active
bc5c4a50-e2e3-42a7-ae5f-214487a6cba4 baseos-CentOS9-stream-v2 active
ee29fab1-25b2-4bde-8d7b-538976846c84 baseos-Debian-10-v2 active
771433be-311f-4f9c-af82-060fb692c506 baseos-Debian-11-v1 active
61450471-1d15-48ca-af2a-8476cd54b7d8 baseos-Rocky-8.5-v2 active
358ca60a-e5c8-41c3-b9f5-400bb67f179d baseos-Ubuntu-20.04-v5 active
12e94670-f453-462f-99cb-d9e344d90248 baseos-Ubuntu-22.04-v2 active
ffb90109-7bd4-43c3-87fc-a56e2e4058c0 baseos-openSUSE-Leap-15.3-v2 active

[cesgaxuser@openstack-cli ~]$ openstack image list -f value -c Name
baseos-AlmaLinux-8.4-v3
baseos-CentOS8-stream-v3
baseos-CentOS9-stream-v2
baseos-Debian-10-v2
baseos-Debian-11-v1
baseos-Rocky-8.5-v2
baseos-Ubuntu-20.04-v5
baseos-Ubuntu-22.04-v2
baseos-openSUSE-Leap-15.3-v2

[cesgaxuser@openstack-cli ~]$ openstack image list -f value -c Name -c ID
52a004ff-2a0f-42da-b93c-bbc1b366fc9c baseos-AlmaLinux-8.4-v3
b39960c4-1f13-408f-8266-2fbf17079539 baseos-CentOS8-stream-v3
bc5c4a50-e2e3-42a7-ae5f-214487a6cba4 baseos-CentOS9-stream-v2
ee29fab1-25b2-4bde-8d7b-538976846c84 baseos-Debian-10-v2
771433be-311f-4f9c-af82-060fb692c506 baseos-Debian-11-v1
61450471-1d15-48ca-af2a-8476cd54b7d8 baseos-Rocky-8.5-v2
358ca60a-e5c8-41c3-b9f5-400bb67f179d baseos-Ubuntu-20.04-v5
12e94670-f453-462f-99cb-d9e344d90248 baseos-Ubuntu-22.04-v2
ffb90109-7bd4-43c3-87fc-a56e2e4058c0 baseos-openSUSE-Leap-15.3-v2
```

### Useful commands
Listing images:
```
# public
openstack image list
# community
openstack image list --community
```

Listing flavors:
```
openstack flavor list
```

Listing security groups:
```
openstack security group list
```

Listing networks:
```
openstack network list
```

Listing key pairs:
```
openstack keypair list
```

Launching a new instance:
```
openstack server create --image baseos-Rocky-8.5-v2 --flavor m1.1c1m --key-name javicacheiro --network provnet-formacion-vlan-133 --security-group SSH --flavor m1.1c1m my-first-vm
```
for the image, network, flavor, etc. we can provide the names and if we want to avoid naming clashes we can always use the `ID`.

Listing existing instances:
```
openstack server list
```

Show details about a given instance:
```
openstack server show my-first-vm
```

Deleting an instance:
```
openstack server delete my-first-vm
```

# Appendix
## Scripting
For scripting it is useful to list the instance names and their ip addresses:
```
openstack server list -f value -c Name -c Networks
```

For a given server we can get its addresses and load them in a shell variable using:
```
eval $(openstack server show -f shell -c addresses my-first-vm)
```

If we are controlling the launching process with a python program then getting the information in json format it is also useful:
```
openstack server show -f json my-first-vm
```

We can wait for the server creation to finish using `--wait`:
```
openstack server create --wait --flavor m1.1c1m --image cirros-0.6.1 --key-name javicacheiro --security-group SSH test-cirros
```

When creating an instance we can get its ID using:
```
openstack server create -f value -c id --flavor m1.1c1m --image cirros-0.6.1 --key-name javicacheiro --security-group SSH test-cirros
```
It also works if we set the format options after the server name:
```
openstack server create -f value -c id --flavor m1.1c1m --image cirros-0.6.1 --key-name javicacheiro --security-group SSH test-cirros -f value -c id
```

So we can easily store the IDs and then work with them later on in a script:
```bash
master=$(openstack server create -f value -c id --wait --flavor m1.1c1m --image cirros-0.6.1 --key-name javicacheiro --security-group SSH test-master)

for n in {1..4}; do
    worker[$n]=$(openstack server create -f value -c id --wait --flavor m1.1c1m --image cirros-0.6.1 --key-name javicacheiro --security-group SSH test-worker-$n)
done

openstack server show $master
for n in {1..4}; do
    openstack server show ${worker[1]}
done
```

## Key pair creation
Generating a new key pair and storing the private key locally:
```
openstack keypair create my-first-key > my-first-key
```

We have to set the right permissions for the key:
```
chmod 600 my-first-key
```

To connect use:
```
ssh -i my-first-key cesgaxuser@my-vm-address
```

Uploading an existing public key:
```
openstack keypair create --public-key ~/.ssh/id_rsa.pub my-second-key
```

## Security group creation

```
openstack security group create ssh
```
The **egress** rules are automatically created:
```
openstack security group show ssh
```

We have to add the additional rule to allow **ingress** ssh traffic:
```
openstack security group rule create --ingress --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 ssh
```

We can also allow icmp for ping:
```
openstack security group rule create --ingress --protocol icmp --remote-ip 0.0.0.0/0 ssh
```

This is the final result:
```
openstack security group show ssh
```

## Resizing a server
There is a bug and launching the resize only works from command line:
- https://bugs.launchpad.net/kolla-ansible/+bug/1944220
- https://bugs.launchpad.net/horizon/+bug/1940834

Step 1:
```
openstack server resize --flavor m1.2c4m my-server
```
IMPORTANT: This will automatically shutdown and reboot the server with the new resources.

Step 2:
After that you can confirm or revert the change (but the machine is already rebooted).
```
openstack server resize confirm my-server
```
You can also perform this step from the web interface.

If we are not satisfied with the change we can revert it:
```
openstack server resize revert my-server
```

## Resizing a volume
You can extend the size a volume with:
```
openstack volume set --size 40 xclarity-3.6.0-volume
```
After doing that you will have to also do the pertinent changes in the filesystem.

IMPORTANT: Act with special care if you try to reduce the size of a volume.

## Volume backups
```
openstack volume backup list
openstack volume backup create --name mariadb-data-backup-2 mariadb-data
openstack volume backup delete mariadb-data-backup-1
```

To force backup of an in-use volume (not recommened):
```
openstack volume backup create --force --name mariadb-data-backup-2 mariadb-data
```

## Creating a floating IP
We can create a floating IP that we can later add to our servers:
```
openstack floating ip create public-default
```

We create the floating IP address in the `public-default` external network. Foating ips can only be created in networks flagged as external (see the networking unit).

## Adding resources to a server
We can add resources (floating ip, volume, security group, network, port) to an existing server.

Add a floating IP to a server:

    openstack server add floating ip <server> <ip-address>

Add a fixed IP to a server:

    openstack server add fixed ip --fixed-ip-address <ip-address> <server> <network>

Add a volume to a server:

    openstack server add volume <server> <volume>

Add a security group to a server:

    openstack server add security group <server> <group>

Add a new network to the server:

    openstack server add network <server> <network>

Add a new port to the server (a port has its own MAC and IP):

    openstack server add port <server> <port>

NOTE: You can not add a keypair to a server once it is running because the keys are only configured the first time the server is started.

## Images
List existing images:

    openstack image list

Uploading an existing image so it is available in Glance:
```
openstack image create --disk-format raw --container-format bare --file cirros-0.5.1-x86_64-disk.raw  cirros
```

We can then tune the permissions, default is private and unprotected:
- Visibility:
  - Private: Image is inaccessible to the public (default)
  - Public: Image is publicly available (only admin can set an image as public)
  - Shared: Image can be shared
  - Community: Image is accessible to the community
- Protected against deletion:
  - Unprotected: Allow image to be deleted (default)
  - Protected: Prevent image from being deleted

```
openstack image set --private --protected cirros
```

IMPORTANT: Since our storage backend for OpenStack is Ceph: **Using QCOW2 for hosting a virtual machine disk is NOT recommended**. If you want to boot virtual machines in Ceph (ephemeral backend or boot from volume), please use the raw image format within Glance.

To convert a qcow2 image into raw use:
```
qemu-img convert -f qcow2 -O raw image.img image.raw
```

We can get existing images for Centos, Debian, Ubuntu, RHEL, Arch Linux FreeBSD or Microsfot Windows in:
- [Get images](https://docs.openstack.org/image-guide/obtain-images.html)

Labs:
- [Uploading Cirros image](labs/uploading_cirros_image.md)
- [Uploading Ubuntu 22.10](labs/uploading_ubuntu_22_10.md)

## Sharing an image with other people
Set the image as shared if needed:

    openstack image set --shared cirros

Share the image with your collaborator's project (IMPORTANT: you have to use the project id, not the project name):

    openstack image add project --project-domain default cirros 44d865d39c904452aa4e8e65fced36ae

Verify the new members appear as pending:

    openstack image member list cirros

Give the ID of the shared image to your collaborator.

Then the collaborator has to accept the shared image using the ID you provided:

    openstack image set --accept ee29fab1-25b2-4bde-8d7b-538976846c84

From this moment the image will be appear listed in the collaborator's project.

If you want to unshare the image use:

    openstack image remove project --project-domain default cirros bigdata

## Downloading an image
We can download an image
```
openstack image save --file cirros.img cirros
```

The downloaded image format will depend on the format of the source image, we can see the format of a given file with:
```
[cesgaxuser@openstack-cli tmp]$ file cirros.img
cirros.img: QEMU QCOW Image (v3), 117440512 bytes
```

Unfortunately we can not currently download a volume, but we can convert it to an image and then download it.

## Creating a volume from a image
We can create a volume from an image with:
```
openstack volume create --size 20 --bootable --image baseos-Rocky-8.5-v2 my-rocky-volume
```

## Creating a volume and attaching it to a server
It is a good practice to have a data volume:
```
openstack volume create --size 20 my-volume
```

You can now check that the new volume has been created and it is currently not attached to any server:
```
openstack volume list
```

Then you can attach it to the server:
```
openstack server add volume my-server my-volume
```

If you list the volumes again you will now see the volume as attached to the server:
```
openstack volume list
```
And finally, from the server you have to format it:
```
sudo -s
mkfs.xfs -L $(hostname -s) /dev/vdb
echo "LABEL=$(hostname -s)       /data   xfs     defaults        0 0" >> /etc/fstab
mkdir /data
mount /data
```

## Creating a read-only volume
From the CLI we can create a read-only volume using the option `--read-only`:
```
openstack volume create --read-only --size 20 my-read-only-volume
```

## Creating a bootable volume
In case we want to use the volume as the boot volume of an instance we have to set its `bootable` flag:
```
openstack volume create --bootable --size 20 my-bootable-volume
```

## Cloning a volume
You can clone a volume using:
```
openstack volume create --source my-volume my-volume-clone
```

## Transfer a volume to another project
We will create a sample volume:
```
openstack volume create --size 20 --bootable --image baseos-Rocky-8.5-v2 my-rocky-volume-share-test
```

Now we create a transfer request:
```
openstack volume transfer request create my-rocky-volume-share-test
```

We copy the `auth_key` and `id` fields, you will need them to accept the image in the other project.

Now change to the other project and run:
```
openstack volume transfer request accept --auth-key cb8aad677356e101 f7515a7f-3078-4d53-95d3-1705bce7b601
```

We can now see that the volume appears under the new project and it has dissappeared from the original project:
```
openstack volume list
```

## Showing the console URL
To see the console URL of a given server:
```
openstack console url show my-server
```
then you can just connect to the URL returned.

## Networks
List existing networks:
```
openstack list networks
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

List existing ports (a port is like a virtual NIC with its own mac address and also an associated IP address, they are automatically created when you boot a server and associate it to a network):

    openstack list ports

## Creating a tenant network
We can create a tenant network using:
```bash
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

## Creating a server with a fixed IP
We can create a server with a fixed IP:
```
openstack server create --nic net-id=private,v4-fixed-ip=192.168.1.123 --flavor m1.1c1m --image cirros vm1
```

## Assigning a fixed IP to a server using a port
To create a port with a fixed ip address:
```
openstack port create --network private --fixed-ip subnet=subpriv,ip-address=192.168.1.23 my_port_1
```

When using the previous command we must ensure that the IP requested is not currently allocated.

Sometimes it is convenient to create the port without specifying a specific address so that one available IP of the allocation pool will be assigned to it (this IP will remain associated to this port independetly if the instance using it is deleted):
```
openstack port create --network private my_port_2
```

To attach the port to a VM:
```
openstack server add port vm_nonet_1 my_port_1
```

## Labs
- [Project Lab: Installing OpenSearch in single node mode](../../project-lab/opensearch/single-node/installing_opensearch_single_node.md)

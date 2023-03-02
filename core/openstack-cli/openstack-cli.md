# Openstack-CLI

## Installing openstack-cli
First we need to install the CLI tools. We will do it in the following lab:
- [Installing openstack-cli lab](labs/installing_openstack-cli)

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

## Booting instance options (persistent or non-persistent storage)
There are different options for booting a server:

- Create server from image. No volume is created, data will be deleted when the server is deleted.
```
openstack server create --image <image>

openstack server create --flavor m1.1c1m --image cirros-0.6.1 --key-name javicacheiro --security-group SSH vm-from-image
```

- Create a volume of the given size from a image and use it as boot disk. The volume will be kept when the server is deleted.
```
openstack server create --boot-from-volume <volume-size> --image <image>

openstack server create --boot-from-volume 10 --flavor m1.1c1m --image cirros-0.6.1 --key-name javicacheiro --security-group SSH vm-from-image-and-boot-from-volume-option
```

- Boot from an existing volume
```
openstack server create --volume <volume> ...

openstack server create --volume 5d62e119-c607-4e43-a599-4262283c6139 --flavor m1.1c2m --key-name javicacheiro --security-group SSH vm-from-volume
```

- Boot from snapshot
openstack server create --snapshot <snapshot>

- Ephemeral: Create and attach a local ephemeral block device.
  - Data is lost when the instance is deleted
  - It does not allow live migration so it is not recommended
  - In our case the ephemeral disk is not created in the local node but also in ceph in a dedicated pool. This avoids that a local disk failure causes the instance to fail.
  - By default our flavors do not allow the creation of ephemeral storage (limit set to 0)

```
openstack server create --ephemeral size=<size> --image <image> ...
openstack server create --ephemeral 5 --image cirros-0.6.1 --flavor m1.1c1m --key-name javicacheiro --security-group SSH vm-ephemeral
```

Ephemeral VMs are stored in a dedicated ceph pool called "ephemeral-vms"
```
c27-17
/usr/libexec/qemu-kvm -name guest=instance-0000d21b,debug-threads=on ... -blockdev {"driver":"rbd","pool":"ephemeral-vms","image":"4689e7a4-e3ac-49b5-b790-17a70b6b5026_disk"
...
[root@c26-1 ~]# rbd ls --pool ephemeral-vms | grep 4689e7a4-e3ac-49b5-b790-17a70b6b5026_disk
4689e7a4-e3ac-49b5-b790-17a70b6b5026_disk
[root@c26-1 ~]# rbd info --pool ephemeral-vms 4689e7a4-e3ac-49b5-b790-17a70b6b5026_disk
rbd image '4689e7a4-e3ac-49b5-b790-17a70b6b5026_disk':
        size 40 GiB in 5120 objects
        order 23 (8 MiB objects)
        snapshot_count: 0
        id: 82379d9caf8d67
        block_name_prefix: rbd_data.82379d9caf8d67
        format: 2
        features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
        op_features:
        flags:
        create_timestamp: Thu Jan 19 18:15:04 2023
        access_timestamp: Mon Jan 30 18:25:33 2023
        modify_timestamp: Mon Jan 30 18:25:02 2023
        parent: glance-images/61450471-1d15-48ca-af2a-8476cd54b7d8@snap
        overlap: 2 GiB

```
```
[root@c26-1 ~]# rbd info --pool cinder-volumes volume-8b4f70c7-5fca-430c-8788-0dc5ea0063ac
rbd image 'volume-8b4f70c7-5fca-430c-8788-0dc5ea0063ac':
        size 40 GiB in 5120 objects
        order 23 (8 MiB objects)
        snapshot_count: 0
        id: 67f6347ace15bb
        block_name_prefix: rbd_data.67f6347ace15bb
        format: 2
        features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
        op_features:
        flags:
        create_timestamp: Mon Jan 16 20:58:48 2023
        access_timestamp: Wed Jan 18 21:30:09 2023
        modify_timestamp: Wed Jan 18 21:30:09 2023
        parent: glance-images/6f1c382c-e361-46e6-ae41-305e93c67140@snap
        overlap: 2 GiB
```

NOTE: If you keep instances in shutoff state the hypervisor continues to reserve its resources for when it is started again. Also in the case of ephemeral images the volume is kept.


- user-data: User data file to serve from the metadata server
- file: File(s) to inject into image before boot (repeat to set multiple files)


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
openstack security group rule create --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 ssh
```

We can also allow icmp for ping:
```
openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 ssh
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

## Downloading a image locally
We can download a image
```
openstack image save --file cirros.img cirros
```

The downloaded image format will depend on the format of the source image, we can see the format of a given file with:
```
[cesgaxuser@openstack-cli tmp]$ file cirros.img
cirros.img: QEMU QCOW Image (v3), 117440512 bytes
```

Unfortunately we can not currently download a volume, but we can convert it to an image and then download it.

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

## Network
List existing networks:

    openstack list networks

List existing ports (a port is like a virtual NIC with its own mac address and also an associated IP address, they are automatically created when you boot a server and associate it to a network):

    openstack list ports

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
- [Uploading Cirros image](labs/uploading_cirros_image)
- [Uploading Ubuntu 22.10](labs/uploading_ubuntu_22_10)

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

## Creating a port
To create a port with a fixed ip address:
```
openstack port create --network private --fixed-ip subnet=subpriv,ip-address=192.168.1.23 my_port_1
```

To create a port without a specific address:
```
openstack port create --network private my_port_2
```

To attach the port to a VM:
```
openstack server add port vm_nonet_1 my_port_1
```

## Showing the console URL
To see the console URL of a given server:
```
openstack console url show my-server
```
then you can just connect to the URL returned.

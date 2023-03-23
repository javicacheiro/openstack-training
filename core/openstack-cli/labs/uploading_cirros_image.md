# Uploading Cirros image
Cirros is a popular image use for testing.

In this lab we will download it, convert it to raw format and upload it to OpenStack.

## Download cirros qcow2 image
We will download the cirros image:
```
curl -L -O http://download.cirros-cloud.net/0.6.1/cirros-0.6.1-x86_64-disk.img
```

You can check in which format it is the image using the `file` command:
```
[cesgaxuser@openstack-cli ~]$ file cirros-0.6.1-x86_64-disk.img
cirros-0.6.1-x86_64-disk.img: QEMU QCOW Image (v3), 117440512 bytes
```

## Convert from qcow2 to raw for ceph
To do the conversion we will use the `qemu-img` tool. First we have to install it:
```
sudo dnf -y install qemu-img
```

And now we can use `qemu-img` it to convert the image from qcow2 to raw:
```
qemu-img convert -f qcow2 -O raw cirros-0.6.1-x86_64-disk.img cirros-0.6.1-x86_64-disk.raw
```

## Upload the image to OpenStack
Finally we will upload the image to OpenStack:
```
openstack image create --disk-format raw --container-format bare --file cirros-0.6.1-x86_64-disk.raw  your-username-cirros-0.6.1
```

## Verify
We can verify that the new image has been uploaded, listing existing images:
```
openstack image list
```

## Testing
We can now launch a new instance using this image:
```
openstack server create --flavor m1.1c1m --image your-username-cirros-0.6.1 --key-name your-key-name --security-group SSH your-username-test-cirros
```

List running instances:
```
openstack server list
```

Connect to the instance:
```
ssh cirros@instance-ip-address
```

Cirros is based on linux so you will find the typical commands.

## Cleaning up
Finally, we will clean up.

- Delete the instance:
```
openstack delete your-username-test-cirros
```
- Delete the image from Glance:
```
openstack image delete your-username-cirros-0.6.1
```


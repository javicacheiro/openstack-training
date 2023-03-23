# Uploading Ubuntu 22.04
In this lab we will dowload, convert and upload the latest Ubuntu version.

The steps will be very similar for other popular distributions that provide ready-to-use cloud images.

## Download ubuntu qcow2 kvm image
Canonical provides ready to use cloud images that we can obtain from the general openstack obtain images page:
- https://docs.openstack.org/image-guide/obtain-images.html

Or more specifcially in this case we will get them from:
- https://cloud-images.ubuntu.com/releases/

In the case of Ubuntu 22.10 we can get it from:
- https://cloud-images.ubuntu.com/releases/22.10/release-20230112/


We can download it with:
```
curl -O https://cloud-images.ubuntu.com/releases/22.10/release-20230112/ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img
```

Now we can check the format of the image and see that it is in QCOW format:
```
[cesgaxuser@openstack-cli ~]$ file ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img
ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img: QEMU QCOW Image (v3), 3758096384 bytes
```

## Convert from qcow2 to raw for ceph
To do the conversion we will use the `qemu-img` tool. If not installed previously, we have to install it:
```
sudo dnf -y install qemu-img
```

And now we can use `qemu-img` it to convert the image from qcow2 to raw:
```
qemu-img convert -f qcow2 -O raw ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img ubuntu-22.10-server-cloudimg-amd64-disk-kvm.raw
```


## Upload the image to OpenStack
Finally we will upload the image to OpenStack:
```
openstack image create --disk-format raw --container-format bare --file ubuntu-22.10-server-cloudimg-amd64-disk-kvm.raw ubuntu-22.10-server-cloudimg-amd64
```

## Verify
We can verify that the new image has been uploaded, listing existing images:
```
openstack image list
```

## Testing
We can now launch a new instance using this image:
```
openstack server create --flavor m1.1c1m --image your-username-ubuntu-22.10-server-cloudimg-amd64 --key-name your-key-name --security-group SSH your-username-test-ubuntu
```

List running instances:
```
openstack server list
```

Connect to the instance:
```
ssh ubuntu@instance-ip-address
```

## Cleaning up
Finally, we will clean up.

- Delete the instance:
```
openstack delete your-username-test-ubuntu
```
- Delete the image from Glance:
```
openstack image delete your-username-ubuntu-22.10-server-cloudimg-amd64
```

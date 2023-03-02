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


curl -O https://cloud-images.ubuntu.com/releases/22.10/release-20230112/ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img

We can check the format of the image and see that it is in QCOW format:
```
[cesgaxuser@openstack-cli ~]$ file ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img
ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img: QEMU QCOW Image (v3), 3758096384 bytes
```

qemu-img convert -f qcow2 -O raw ubuntu-22.10-server-cloudimg-amd64-disk-kvm.img ubuntu-22.10-server-cloudimg-amd64-disk-kvm.raw


openstack image create --disk-format raw --container-format bare --file ubuntu-22.10-server-cloudimg-amd64-disk-kvm.raw ubuntu-22.10-server-cloudimg-amd64


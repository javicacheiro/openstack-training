# Storage in OpenStack
## Introduction
There are two main types of storage in Openstack:
- Images: managed by the Glance component
- Volumes: managed by the Cinder component

Images allow to boot multiple instances and each instance will create its own volume (persistent or ephemeral).

Both images and volumes are stored in a block storage backend, in our case ceph RBD.

For more information:
- [Openstack Storage Concepts](https://docs.openstack.org/arch-design/design-storage/design-storage-concepts.html)

In this lesson we will learn how to:
- Looking for existing images: public and community images
- Uploading a new image
- Customizing an existing image
- Installing a new system from a ISO
- Creating a volume
- Creating a snapshot
- Creating a backup
- Creating a new image from a existing one
- Booting from a volume
- Booting from a snapshot
- Shutting down an instance and starting it later
- Persistent instance vs ephemeral instance

## Images
Under `Compute > Images` you can see the existing images.

By default you only see the list of supported images (**public images**).
![Images](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-images.png?raw=true)

You can see additional images if you include also **community images** which include images that are not LTS, images that are not yet fully tested or old versions of existing images. To do that click in the search box and select "Visibility" and then "Community".

![Community images](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-images-comunity.png?raw=true)

Additionaly you can have **private images** that are only available in your project.

## Uploading an new image
With `Compute > Images: Create Image` you can upload a new image.
![Images](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-images-upload-1.png?raw=true)
![Images](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-images-upload-2.png?raw=true)
![Images](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-images-upload-3.png?raw=true)

There are different options for visibility and deletion protection:
- Visibility:
  - Private: Image is inaccessible to the public (default)
  - Public: Image is publicly available (only admin can set an image as public)
  - Shared: Image can be shared
  - Community: Image is accessible to the community
- Protected against deletion:
  - Unprotected: Allow image to be deleted (default)
  - Protected: Prevent image from being deleted

IMPORTANT: Since our storage backend for OpenStack is Ceph: **Using QCOW2 for hosting a virtual machine disk is NOT recommended**. If you want to boot virtual machines in Ceph (ephemeral backend or boot from volume), please use the raw image format within Glance.

To convert a qcow2 image into raw use:
```
qemu-img convert -f qcow2 -O raw image.img image.raw
```

We can get existing images for Centos, Debian, Ubuntu, RHEL, Arch Linux FreeBSD or Microsfot Windows in:
- [Get images](https://docs.openstack.org/image-guide/obtain-images.html)

## Customizing an existing image: creating a volume from a image
We can create a volume from an existing image so this volume can then used to boot an instance or to do manual modifications to the image (eg. to later create a new image):

We go to the Images menu, we locate the image that we are interested in (eg. baseos-Rocky-8.5-v2) and in the image options we select "Create Volume":
![volume from image 1](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-volume-from-image-1.png?raw=true)
![volume from image 2](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-volume-from-image-2.png?raw=true)

Then we perform customizations in the volume in any of these two ways:
- Attaching the volume to an existing instance
- Booting from the new volume

Once we are happy with the changes we can upload the volume as an image (more details in "Creating an image from a volume" section):

## Creating an image from a volume
We can convert a volume in an image by going to the Volumes section, we locate the volume we are interested in, and in the volume options we select: "Upload to image":
![volume to image 1](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-volume-to-image-1.png?raw=true)
![volume to image 2](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-volume-to-image-2.png?raw=true)

## Installing a new system from an ISO
This procedure allows us to create an image for any operating system that can run in the `x86_64` architecture.

The process is the following:
- We upload the installation ISO as an image
- We create an instance from this ISO
- We create a volume that will be the root disk where we will do the installation
- We attach the volume to the instance
- We perform the installation
- We stop the instance
- We dettach the volume
- We start an instance from the volume
- We do any additional customizations
- We upload the final volume as an image

During the installation we can use the server graphical console to interact with the installer. It is accessible in:
- Compute > Instances
- Select your instace
- Go to the "Console" tab

The console is also very useful when the instance crashes.

**Lab**:
- [Installing Rocky 9.1 from ISO](labs/installing_rocky_9.1_from_iso.md)

## Creating a volume and attaching it to an instance
It is a good practice to separate the data from the base system, for that we create a new volume:
![create volume 1](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-volume-1.png?raw=true)
![create volume 2](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-volume-2.png?raw=true)

Once created we have to attach it to the instance, for that we go to the Instances list, we locate the instance we are interested in, and in the instance options we select "Attach Volume":
![attach volume](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-attach-volume-1.png?raw=true)
![attach volume](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-attach-volume-2.png?raw=true)


Finally we have to connect to the instance, format the volume and mount it:
```
sudo -s
mkfs.xfs -L $(hostname -s) /dev/vdb
echo "LABEL=$(hostname -s)       /data   xfs     defaults        0 0" >> /etc/fstab
mkdir /data
mount /data
```

## Creating a bootable volume
In case we want to use the volume as the boot volume of an instance we have to set its `bootable` flag, to do that we go to the Volumes menu, we locate the volume and the volume options we select "Edit Volume":
![bootable volume](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-bootable-volume-1.png?raw=true)
![bootable volume](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-bootable-volume-2.png?raw=true)

## Extending a volume
In case we want to extend the size of a volume go to the Volumes menu, we locate the volume and the volume options we select "Extend Volume":
![extend volume](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-extend-volume-1.png?raw=true)
![extend volume](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-extend-volume-2.png?raw=true)

After doing that you will have to also do the pertinent changes in the filesystem.

## Creating a snapshot
We can create a snapshot of an instace.
![snapshot](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-snapshot-1.png?raw=true)
![snapshot](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-snapshot-2.png?raw=true)

IMPORTANT: This will only create a snapshot of the boot volume of the instance.

If the instance has volumes attached we have to create also snapshots of these volumes, in the Volumes menu, locate the volume and in the options select "Create Snapshot":
![snapshot](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-snapshot-3.png?raw=true)
![snapshot](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-snapshot-4.png?raw=true)

NOTE: To avoid issues, the snapshots should be created with the instances stopped and the volumes unmounted.

## Instance snapshots vs Volume snapshots
When creating snapshots of instances we have the option of creating the snapshot from the instance options, this will create a **instance snapshot**, or we can also do it from the volume corresponding to the system, this will create a **volume snapshot**.

It is important to notice the following:
- **instance snapshots** are managed by the Glance service so they appear as **Images**.
- **volume snapshots** are managed by the Cinder service so they appear as **Volumes**.

## Creating a volume backup
We can create a backup of a volume:
![backup](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-backup-1.png?raw=true)
![backup](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-create-backup-2.png?raw=true)

The main difference is that in the case of the backup the whole volume is stored (in the snapshots the ceph snapshot functionality is used) and we can download it.

If the volume is attached the backup will end in error, so you will have stop the instance and dettach the volume first. For that, after stopping the instance, go to the Volumes menu, locate the volume and select "Manage Attachments":
![dettach](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-dettach-volume-1.png?raw=true)
![dettach](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-dettach-volume-2.png?raw=true)
![dettach](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-dettach-volume-3.png?raw=true)

IMPORTANT: If you really need a backup of the data in the instance you install in the instance our official backup software.

## Persistent vs ephemeral
It is important to understand the distinction between ephemeral storage and persistent storage:
- Ephemeral storage: If the disk associated with the VM is ephemeral, this means that **the disk disappears when the VM is deleted**.
- Persistent storage: The disk associated with the VM appears as a volume and it is not deleted when the VM is deleted. **You have to remember to delete it manually when needed.**

## Booting instance options
There are different options for booting that will define how storage is allocated to the new instance and from where the main disk of the instance will be created.

These options are presented in horizon in the `Source` tab of the launch instance wizard:

![Boot options](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-boot-options.png?raw=true)

We can select the boot source:
- Image
- Instance Snapshot
- Volume
- Volume Snapshot

And then there is a important option: "Create New Volume". If we select "No" then we will create a **ephemeral** instance, this means that no persistent storage is allocated and all dat will be lost when the instance is deleted.

## Final lab
Lab:
- [Storage lab](labs/storage_lab.md)

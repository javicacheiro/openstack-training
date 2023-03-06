# Installing Rocky 9.1 from ISO
In this lab we will install the Rocky Linux distribution from a ISO.

The same procedure can be used to install from any other ISO.

**For simplicity the ISO is already uploaded and available under images so you can start in the third step: "Create a bootable volume".**

NOTE: The openstack-cli commands are included for reference.

## Download the ISO
We can download the ISO using curl:
```
curl -O https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.1-x86_64-minimal.iso
```

## Upload the ISO to OpenStack
We can upload the image in the `Compute > Images` menu: "Create Image". Select as format "ISO".

From the CLI this can be done with:
```
openstack image create --private --disk-format iso --container-format bare --file Rocky-9.1-x86_64-minimal.iso Rocky-9.1
```

## Create a bootable volume
Create a bootable volume:
- Name: `<username>-rocky-installation`
- Size: 4GB

Then edit it and set the bootable flag.

NOTE: We create a bootable volume so we can later on boot from it and customize the image. At the end we will upload the volume as a image.

From the CLI this can be done with:
```
openstack volume create --size 4 --bootable your-username-rocky-installation
```

## Create a new instance
Create a new instance:
- Name: `<username>-install-from-iso-lab`
- Source: Rocky-9.1
- Create New Volume: No (ephemeral instance)
- Flavor: m1.1c1m
- Networks: provnet-formacion-vlan-133
- Securiry groups: SSH
- Key Pair: your keypair

## Attach the volume
Once the instance is started in the instance options select: "Attach Volume" and attach the previously created volume.

From the CLI this can be done with:
```
openstack server add volume your-username-install-from-iso-lab your-username-rocky-installation
```

## Connect to the console
In the instance options select "Console".

From the CLI this can be done with:
```
openstack console url show your-username-install-from-iso-lab
```
then you can just connect to the URL returned (never share it).

## Perform the installation
Now we can just perform the installation as we would do in a physical server.

For example use the following selections (for a basic installation):
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-1.png?raw=true)
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-2.png?raw=true)
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-3.png?raw=true)
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-4.png?raw=true)
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-5.png?raw=true)
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-6.png?raw=true)
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-7.png?raw=true)
![rocky](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-rocky-installation-8.png?raw=true)

## Delete the instance
When the installation is finished we click the final restart button from the wizard and after that we delete the instance.

## Start an instance from the volume
Now we will start a new instance using the volume.
- Name: `<username>-temp-server`
- Source:
  - Select Boot Source: Volume
  - Select our volume: `<username>-rocky-installation`
- Flavor: m1.1c1m
- Networks: provnet-formacion-vlan-133
- Security groups: SSH
- Key Pair: your keypair

## Perform additional customizations
We can now connect to our instance using the user we just created during installation:
```
ssh <username>@<ip_address>
```

After that we can change to the root account using:
```
su -
```
and providing the root password we configured previously.

### Adding the cloud-init service
cloud-init is a service that takes care of the initialization of the cloud image. It is able to obtain the context information from OpenStack and set the image accordingly.

#### cloud-init installation
Installing cloud-init:
```
dnf install cloud-init
systemctl enable cloud-init
```

cloud-init only runs the first time a machine boots, in this case we want that it runs in the next start of the server, not now.

Just in case, we will stop cloud-init and clean it,  so it will run in the next boot:
```
systemctl stop cloud-init
cloud-init clean --logs
```

We will also clean the package cache:
```
dnf clean all
```

#### How cloud-init contextualizes the instance
The contextualization information is obtained from the resources inside the meta-data url using http:
```
# To list all available metadata fields
curl http://169.254.169.254/latest/meta-data

# Then we can retrieve each field with
curl http://169.254.169.254/latest/meta-data/hostname
curl http://169.254.169.254/latest/meta-data/local-ipv4
curl http://169.254.169.254/latest/meta-data/public-keys/
curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key
```

#### Customizing cloud-init
In the *baseos* images we configure cloud-init so we use `cesgaxuser` for all distros. If not, it is common that each cloud image uses a different user depending on the distro.

We will customize our cloud-init installation so it also uses the `cesgaxuser`, for that we will edit the `/etc/cloud/cloud.cfg` config file and set:
```
system_info:
   # This will affect which distro class gets used
   distro: rocky
   # Default user name + that default users groups (if added/used)
   default_user:
     name: cesgaxuser
     lock_passwd: true
     gecos: Cloud User
     groups: [adm, systemd-journal]
     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
     shell: /bin/bash
```


## Verify
We can now reboot the instance and check the changes:
```
reboot
```

Now we will be able to connect using the `cesgaxuser` and the configured key pair in openstack.
```
ssh cesgaxuser@<ip_address>
```

You can now verify the installation and check that everything is configured as you want.

To finish, since cloud-init only runs the first time a machine boots and we have already booted the volume, we will have to clean it so it runs the next time the server is started.

Clean cloud-init so it will run in the next boot:
```
sudo -s
systemctl stop cloud-init
cloud-init clean --logs
rm /home/cesgaxuser/.ssh/authorized_keys
```

If everything is fine we can now shutdown the instance.
```
shutdown -h now
```

Once it is in the "Shutoff" state we can safely delete the instance.

## Note on SSH server configuration
For cloud images it is recommended to disable password authentication for ssh connections.

To do this we will edit `/etc/ssh/sshd_config`, look for the `PasswordAuthentication` option and set it to "no" (check that you leave it uncommented):
```
PasswordAuthentication no
```

In our case this change is automatically done by cloud-init.

## Upload the final volume as an image
The last step is to upload the volume as an image so we can use it as the source to boot multiple instances.

We will go to `Volumes > Volumes` we locate the volume and in the options menu we select "Upload to Image":
- Image Name: `<username>-rocky-9-custom`
- Disk Format: Raw

Once finished verify that the image size is the right one (sometimes the process of upload can fail and the image is truncated).

NOTE: The image is automatically converted with qemu-img before uploading from Cinder (volumes) to Glance (Images), to speed up the upload process you can select QCOW2 format. For production the recommendation is to use RAW.

## Testing
We can now start a new instance using our new image as source.

## Clean up
When done we can clean up:
- Delete instances
- Delete volumes
- Delete image

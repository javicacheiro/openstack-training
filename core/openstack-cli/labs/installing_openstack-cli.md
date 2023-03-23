# Installing openstack-cli
In this lab we will see how to install the `openstack-cli`.

## Launching the instance
Launch a instance with:
  - Details: Name `<login_name>-openstack-cli`
  - Source: 
    - Choose the source image: baseos-Rocky-8.5-v2
    - Create New Volume: No
  - Flavor: m1.1c2m (1 VCPU, 2GB RAM)
  - Network: provnet-formacion-vlan-133
  - Security Groups: SSH
  - Key Pair: select your key pair

## Updating
It is always a good idea to update the system so we have the latest security patches:
```
sudo dnf -y update
sudo reboot
```

## Adding the openstack repo
Add the `openstack-xena-centos8s.repo` to `/etc/yum.repos.d/`.

For example you can do it as follows:
```
# First we copy the repo file inside the instance
scp openstack-xena-centos8s.repo cesgaxuser@<ip_address>:
# Then we copy the file into /etc/yum.repos.d/
sudo cp openstack-xena-centos8s.repo /etc/yum.repos.d/
```
or if you prefer you can just open the file in the instance and paste the contents.

## Installing openstack-cli
```
sudo dnf -y --enablerepo=centos-openstack-xena install python3-openstackclient
```

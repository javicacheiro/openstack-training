# Automatically installing docker and docker
In this lab we are going to configure our instances so they automatically install docker and vim.

The scripts needed to install vim and docker are available in:
- http://bigdata.cesga.gal/files/install_vim.sh
- http://bigdata.cesga.gal/files/install_docker.sh

## Creating the user data include file
Since the scripts needed are already available in a web server, we only have to create a file that begings with the `#include` directive that lists these URLs:
```
#include
http://bigdata.cesga.gal/files/install_vim.sh
http://bigdata.cesga.gal/files/install_docker.sh
```

## Creating the instance
Now we can create an instance using this include file:
```
openstack server create --user-data user-data.include --flavor m1.1c1m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 test-userdata-include
```

## Verify
We can verify that everyting went fine looking at the cloud-init output log:
```
view /var/log/cloud-init-output.log
```

Then we can verify that vim and docker are installed:
```
which vim
docker ps
```

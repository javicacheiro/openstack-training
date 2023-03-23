# cloud-init
## user-data
When creating a server Openstack allows us to provide a script that will usually be run the first time the instance is booted. 
**This is one of the simplest ways to customize your servers.**

This script is commonly known as `user data`.

Basically openstack will serve the script provided from the metadata server so it can be consumed by the instance initialization software.

## cloud-init
As mentioned *user data* works in conjunction with a instance initialization software that must be installed in the template image that we are using.

The most common cloud instance initialization software is [cloud-init](https://cloud-init.io/).

cloud-init will take care of reading the script provided as user data and execute it the first time the instance boots.

cloud-init basically takes care of:
- Setting the hostname
- Adding the SSH public key to the configured account
- Running user data
- Growing the underlying partition

## How to use user data
Let's see an example of how to use user data to update the software of the base image the first time the instance boots.

We will first create our user data script that we want to be executed, eg. `update.sh`:
```
#!/bin/bash
dnf -y udate
```

And now when creating the server we will provide the user data script:
```
openstack server create --user-data update.sh --flavor m1.1c1m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 test-userdata-basic
```

## Advanced usage
### Include
Instead of providing the content of the user data script it is also possible to provide a URL or a list of URLs so that each file will be downloaded and executed.

In this case the user data file must begin with the `#include` directive, for example:
```
#include
# Include one url per line
# They will be passed to urllib.urlopen so the format must be supported there
http://bigdata.cesga.gal/files/file1.sh
http://bigdata.cesga.gal/files/file2.sh
http://bigdata.cesga.gal/files/file3.mime
```

And then we can create an instance using this include file:
```
openstack server create --user-data user-data.include --flavor m1.1c1m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 test-userdata-include
```

This way this instance will have vim and docker installed automatically the first time it boots.

### Multi-part
It is also possible to use the cloud-init `make-mime` subcommand to generate a MIME multi-part file that can be used to provide different shell scripts and even a cloud-init configuration file in yaml format:
- `cloud-config`: yaml file containing the cloud-init configuration
- `x-shellscript`: the script we want to run

For the most recent versions of cloud-init (`>=22.1`) it is also possible to specify different scripts depending on when we want them to be run:
- `x-shellscript-per-instance`: the script will be only run the first time the instance boots
- `x-shellscript-per-boot`: the script will be run each time the instance boots
- `x-shellscript-per-once`: the script will be run only once

Reference: [Shell script handlers by freq](https://github.com/canonical/cloud-init/pull/1166)

For example we can generate our multi-part mime file with:
```
cloud-init devel make-mime -a myconfig.yaml:cloud-config -a first-time.sh:x-shellscript-per-instance -a always.sh:x-shellscript-per-boot > userdata.mime
```

And then we can create an instance using this multipart file:
```
openstack server create --user-data userdata.mime --flavor m1.1c1m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 test-userdata-multipart
```

NOTE: The URLs in the include directive that we saw previously can point to mime files.

## cloud-init logs
In case of issues with the cloud-init service we can look at the cloud-init logs in:
- /var/log/cloud-init.log
- /var/log/cloud-init-output.log

The first file is the log of the cloud-init service and the second one contains the output of the scripts that have been executed. If there is a failure it will stop.


## Labs
- [Keeping our instances up to date](labs/using_user_data.md)
- [Automatically Installing Docker and Vim](labs/using_user_data_with_include.md)

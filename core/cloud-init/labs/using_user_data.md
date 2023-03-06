# Updating the instance
It is always a good practice to keep software updated, in this lab we will use user data so the instances that we create are always updated the first time they are booted.

This way we will start to work with up to date software.

## Creating the user data script
To do this first we would create a script that updates the software, in this case a ready to use script is already provided named `update.sh`.

You can check its contents and see that it is a simple shell script.

## Launching the instance
Now we can create the instance providing this script as user data:
```
openstack server create --user-data update.sh --flavor m1.1c1m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 curso800-userdata-basic
```

## Verify
Once the instance boots verify `/root/user-data.log` (our script creates it) to see that in fact the script has run.

In case of issues you can look at `/var/log/cloud-init-output.log` and check there the output of the `update.sh` script.

Also check that the software is updated, for that you can run:
```
sudo dnf update
```
and see that all packages are already updated.

You can now **reboot** the instance to verify that the script is only run the first time the instance is booted.

We can also see that the user data is provided to cloud-init by the openstack metadata service (neutron metadata service):
```
curl http://169.254.169.254/latest/user-data
```

You can also see the other metadata provided by the neutron metadata service:
```
curl http://169.254.169.254/latest/meta-data
```

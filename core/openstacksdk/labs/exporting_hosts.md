# Exporting OpenStack instance inventory in /etc/hosts format
Sometimes it is very useful to have the connection information about the instances in openstack in our /etc/hosts file, so that we can connect using the instance names instead of the IP addresses.

In this lab we will develop a simple python script using openstacksdk to enable us to easily export this information from openstanck.

## Developing the tool
First we will create the `clouds.yaml` configuration file using the template provided.

We will place it in the `~/.config/openstack` directory.
```
mkdir -p ~/.config/openstack
cp clouds.yaml ~/.config/openstack
```

Then you can develop the program using any of the `openstacksdk` layers. You can see a sample solution using the quite common "proxy layer" (layer 2) in `export_hosts.py`.

## Using the tool
Then we can just populate the /etc/hosts file with:
```
./export_hosts.py | sudo tee -a /etc/hosts
```

# Installing ClusterShell
In this lab we will install ClusterShell in our Rocky VM.

If you want to use ClusterShell later on my recommendation is to install it locally in your computer.

## Installation
```
sudo dnf install epel-release
sudo dnf install clustershell
```

## Configuration
We will be using a very basic configuration so the only thing we have to do it is to add the VM instances that we want to manage to the `/etc/hosts` so they can be resolved by name.

NOTE: If we use the IP addresses we would not need to add them to `/etc/hosts`.

To list the instances and their IP addresses we can run:
```
openstack server list -c Name -c Networks
```

Or even better we can use the script we developed in the `openstacksdk` lab to export the instance list in `/etc/hosts` format:
```
python3 export_hosts.py
```

And then we edit `/etc/hosts` and append the information:
```
sudo vim /etc/hosts
```

Just for testing create to test instances and include their IPs in `/etc/hosts` and name them node-1 and node-2:
```
10.133.27.101 node-1 node-1.novalocal
10.133.27.110 node-2 node-2.novalocal
```

We include also the `.novalocal` entries that correspond to the default domain configured by openstack in the instances. You can check it running:
```
hostname
```

## Testing
You can now run some commands:
```
clush -l cesgaxuser -bw node-[1-2] echo OK
clush -l cesgaxuser -bw node-[1-2] hostname
clush -l cesgaxuser -bw node-[1-2] --copy /etc/hosts --dest /tmp
```

## Cleanup
When done delete the test instances and, if needed, their volumes.

# Installing an OpenSearch cluster

## Provisioning
We will be need 4 instances.

We can launch them using something like:
```
for n in {1..3}; do
    openstack server create --flavor a1.2c4m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --security-group opensearch --network provnet-formacion-vlan-133 opensearch-$n
done

openstack server create --flavor a1.2c4m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 dashboards
```

NOTE: The **opensearch security group** is already created enabling access to:
- egress: all
- ingress: tcp 9200 (opensearch), 9200 (opensearch inter-node), tcp 5601 (opensearch-dashboards)

NOTE: If you adjust the instance names you will have to **update the hostnames** (by default they get the name of the instance) for the scripts to work (alternatively you can update the scripts):
```
hostnamectl set-hostname opensearch-1
```

In future versions of the `openstack-cli` there will be the option to configure the instance hostname:
- [Configurable instance hostnames](https://specs.openstack.org/openstack/nova-specs/specs/xena/implemented/configurable-instance-hostnames.html)

Alternatively you can also launch the instances using horizon, it is very simple because we can use **count 3** for the opensearch cluster instances:
- Compute -> Instances: Launch Instance:
  - Instance Name: `opensearch`
  - Count: 3
  - Source: baseos-Rocky-8.5-v2
  - Flavor: **a1.2c4m**: 2 cores, 4GB RAM: this is more than enough for the lab, but you have to edit the `openstack/run_docker-opensearch_version.sh` helper script and reduce the memory. For production we would use something like m1.8c16m
  - Networks: provnet-formacion-vlan-133
  - Security Groups: **opensearch**, SSH
  - Key Pair: your imported key pair

Additionaly we will launch another instance and name it `dashboards`.

## Configuration
Add the vm instances to your `/etc/hosts` and to the `/etc/hosts` of the remote servers:
```
# opensearch deployment on openstack
1.2.3.4 opensearch-1 opensearch-1.novalocal
1.2.3.4 opensearch-2 opensearch-2.novalocal
1.2.3.4 opensearch-3 opensearch-3.novalocal
1.2.3.4 dashboards dashboards.novalocal
```

Now we can proceed:
```
clush -l cesgaxuser -bw opensearch-[1-3] sudo dnf -y update

clush -l cesgaxuser -bw opensearch-[1-3] --copy docker.repo --dest /tmp
clush -l cesgaxuser -bw opensearch-[1-3] sudo cp /tmp/docker.repo /etc/yum.repos.d
clush -l cesgaxuser -bw opensearch-[1-3] sudo dnf install -y --enablerepo docker docker-ce
clush -l cesgaxuser -bw opensearch-[1-3] sudo systemctl enable docker

# Before running the following commands: Create and attach a data volume to each instance
clush -l cesgaxuser -bw opensearch-[1-3] --copy configure_data_volume.sh --dest /tmp
clush -l cesgaxuser -bw opensearch-[1-3] sudo /tmp/configure_data_volume.sh

clush -l cesgaxuser -bw opensearch-[1-3] sudo reboot
```

Edit `run_docker-opensearch_version.sh` and set the right IP addresses for the nodes. Then upload it to the nodes and run it:
```
clush -l cesgaxuser -bw opensearch-[1-3] --copy run_opensearch_container.sh --dest /home/cesgaxuser
clush -l cesgaxuser -bw opensearch-[1-3] sudo /home/cesgaxuser/run_opensearch_container.sh
clush -l cesgaxuser -bw opensearch-[1-3] sudo docker ps
```

NOTE: The `vm.max_map_count` kernel setting must be set to at least 262144 for production use, this is done automatically in the `run_docker-opensearch_version.sh` script.
If you restart the virtual machine then you will have to set it again manually or the opensearch container will not boot:
```
sysctl -w vm.max_map_count=262144
```
You can make this change permanent by adding this line to `/etc/sysctl.conf`.


Verify the installation with:
```
curl --insecure -u admin:admin -XGET 'https://opensearch-1:9200/_cat/health?v&pretty'
http --verify no --auth admin:admin 'https://opensearch-1:9200/_cat/health?v&pretty'
```

## Opensearch Dashboards (Kibana)
Once opensearch has started we can start opensearch dashboards (ie. **kibana**).

You will have to edit the `run_opensearch_dashboards_container.sh` to point to the right opensearch instance addresses:
```
clush -l cesgaxuser -bw dashboards --copy run_opensearch_dashboards_container.sh --dest /home/cesgaxuser
clush -l cesgaxuser -bw dashboards sudo /home/cesgaxuser/run_opensearch_dashboards_container.sh
```

Go to opensearch dashboards:

    http://dashboards:5601

credentials are: admin/admin

## Cleanup
To destroy the running cluster:
```
clush -l cesgaxuser -bw opensearch-[1-3] 'sudo docker rm -f $(hostname -s)'
clush -l cesgaxuser -bw opensearch-[1-3] sudo rm -rf /data/opensearch

clush -l cesgaxuser -bw dashboards sudo docker rm -f dashboards
```

Finally delete the nodes:
- Delete the instances
- Delete the volumes

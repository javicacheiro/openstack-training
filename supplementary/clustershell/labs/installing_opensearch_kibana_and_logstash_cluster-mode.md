# Installing an OpenSearch cluster

## Provisioning
We will be creating 4 instances.

You can use horizon with **count 3**:
- Compute -> Instances: Launch Instance:
  - Instance Name: `opensearch`
  - Count: 3
  - Source: baseos-Rocky-8.5-v2
  - Flavor: **a1.2c4m**: 2 cores, 4GB RAM: this is more than enough for the lab, but you have to edit the `openstack/run_docker-opensearch_version.sh` helper script and reduce the memory. For production we would use something like m1.8c16m
  - Networks: provnet-formacion-vlan-133
  - Security Groups: **opensearch**, SSH
  - Key Pair: your imported key pair
- Launch another instance and name it `kibana`

You can also launch them with `openstack-cli` using something like:.
```
for n in {1..3}; do
    openstack server create --flavor a1.2c4m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --security-group opensearch --network provnet-formacion-vlan-133 opensearch-$n
done

openstack server create --flavor a1.2c4m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 kibana
```

NOTE: The **opensearch security group** is already created enabling access to:
- egress: all
- ingress: tcp 9200 (opensearch), tcp 5601 (opensearch-dashboards)

## Configuration
Add the vm instances to your `/etc/hosts` and to the `/etc/hosts` of the remote servers:
```
# opensearch deployment on openstack
1.2.3.4 opensearch-1 opensearch-1.novalocal
1.2.3.4 opensearch-2 opensearch-2.novalocal
1.2.3.4 opensearch-3 opensearch-3.novalocal
1.2.3.4 kibana kibana.novalocal
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
clush -l cesgaxuser -bw opensearch-[1-3] --copy run_docker-opensearch_version.sh --dest /home/cesgaxuser
clush -l cesgaxuser -bw opensearch-[1-3] sudo /home/cesgaxuser/run_docker-opensearch_version.sh
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

You will have to edit the `run_kibana-opensearch_version.sh` to point to the right opensearch instance addresses:
```
clush -l cesgaxuser -bw kibana --copy run_kibana-opensearch_version.sh --dest /home/cesgaxuser
clush -l cesgaxuser -bw kibana sudo /home/cesgaxuser/run_kibana-opensearch_version.sh
```

Go to kibana:

    http://kibana:5601

NOTE: Be careful because kibana by default would resolve to kibana.service.int.cesga.es (the production one)

credentials are: admin/admin

## Cleanup
To destroy the running cluster:
```
clush -l cesgaxuser -bw opensearch-[1-3] 'sudo docker rm -f $(hostname -s)'
clush -l cesgaxuser -bw opensearch-[1-3] sudo rm -rf /data/opensearch

clush -l cesgaxuser -bw kibana sudo docker rm -f kibana
```

Finally delete the nodes:
- Delete the instances
- Delete the volumes

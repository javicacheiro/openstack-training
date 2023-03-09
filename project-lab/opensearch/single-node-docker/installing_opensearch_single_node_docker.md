# Installing Opensearch and Opensearch Dashboards in single-node mode using Docker

Create server:
```
openstack server create --boot-from-volume 20 --flavor m1.2c4m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH --network provnet-formacion-vlan-133 opensearch-single-node-docker
```

Copy the files needed for the lab to the new VM:
```
scp -r opensearch opensearch-dashboards docker.repo cesgaxuser@opensearch-single-node-docker:
```

Connect to the VM and install docker and some useful packages:
```bash
sudo cp docker.repo /etc/yum.repos.d
sudo dnf install -y --enablerepo docker docker-ce docker-compose-plugin bash-completion vim
sudo systemctl start docker
sudo systemctl enable docker
```

We will enable the cesgaxuser to use docker so we do not have to type sudo each time:
```
sudo usermod --append --groups docker cesgaxuser
```
Remember that you have to reconnect for the change in the groups to take effect.

In this lab we will build two container images, one for opensearch and the other for opensearch-dashboards.

## Opensearch
Go to the directory with the Dockerfile for opensearch:
```
cd opensearch
```

Build the container image:
```
docker build -t opensearch .
```

We can now see the image in the local cache (since we did not specify a tag it will appear with the tag `latest`):
```
docker images
```

Before running the container we have to increase the `vm.max_map_count` kernel setting to 262144:
```
sudo sysctl -w vm.max_map_count=262144
```

Now we can run opensearch using docker.

First we will create a network to enable inter-container communication:
```
docker network create opensearch-net
```

Now we can run opensearch using the image we have just built:
```
docker run -d -p 9200:9200 --network opensearch-net -e bootstrap.memory_lock=true --ulimit memlock=-1:-1 --ulimit nofile=65536:65536 -e path.data=/data --name opensearch opensearch
```

Check the logs to see when the service is ready (it takes around 1 minute to start):
```
docker logs opensearch
```

Test it:
```
curl -X GET -u admin:admin --insecure https://localhost:9200
```

## Opensearch Dashboards
Go to the directory with the Dockerfile for opensearch dashboards:
```
cd opensearch-dashboards
```

Build the container image:
```
docker build -t opensearch-dashboards .
```

We can now see the image in the local cache:
```
docker images
```

Now we can run opensearch-dashboards using the image we have just built:
```
docker run -d -p 5601:5601 --network opensearch-net -e OPENSEARCH_HOSTS='["https://opensearch:9200"]' --name opensearch-dashboards opensearch-dashboards
```

Check the logs to see when the service is ready (it takes around 1 minute to start):
```
docker logs opensearch-dashboards
```

Test installation:
```
curl -L -X GET http://localhost:5601
```

## Security group
Now we want to open the ports in the security group so we can connect from the VPN to opensearch dashboards and opensearch:
- Create a security group called opensearch with tcp ports 5601 (opensearch dashboards) and 9200 (opensearch)
  You can do it in the web or using the cli
```
openstack security group create opensearch
openstack security group rule create --ethertype IPv4 --protocol tcp --dst-port 5601 --remote-ip 0.0.0.0/0 opensearch
openstack security group rule create --ethertype IPv4 --protocol tcp --dst-port 9200 --remote-ip 0.0.0.0/0 opensearch
```
- Associate the new security group to the instance
```
openstack server add security group opensearch-single-node-docker opensearch
```
- Connect to: `http://<ip address>:5601` using credentials `admin:admin`

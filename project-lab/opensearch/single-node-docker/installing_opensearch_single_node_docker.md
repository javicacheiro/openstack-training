
OpenSearch (Elasticsearch)
OpenDashboards (Kibana)

Create server:
```
source course-6-project-openrc.sh

openstack server create --boot-from-volume 20 --flavor m1.2c2m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH opensearch-single-node-docker
```

Copy the files:
```
scp -r opensearch opensearch-dashboards cesgaxuser@opensearch-single-node-docker:
```

We will build two container images, one for opensearch and the other for opensearch-dashboards.

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
sysctl -w vm.max_map_count=262144
```

Now we can run opensearch using the image we have just built:
```
docker run -d -p 9200:9200 -e bootstrap.memory_lock=true --ulimit memlock=-1:-1 --ulimit nofile=65536:65536 -e path.data=/data --name opensearch opensearch
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
docker run -d -p 5601:5601 --name opensearch-dashboards opensearch-dashboards
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

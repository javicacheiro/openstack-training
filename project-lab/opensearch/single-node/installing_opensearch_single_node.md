# Installing OpenSearch in single-node
In this lab we will install OpenSearch (Elasticsearch) and OpenDashboards (Kibana) in a single-node.

Create server:
```
source course-1-project-openrc.sh

openstack server create --boot-from-volume 20 --flavor m1.2c2m --image baseos-Rocky-8.5-v2 --key-name javicacheiro --security-group SSH opensearch-single-node
```

Update it with latest security fixes:
```
# Update packages
sudo dnf -y update
# Reboot so we use latest kernel
sudo reboot
```

## Opensearch
Install opensearch:
```
# Add yum repository
sudo curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/opensearch-2.x.repo -o /etc/yum.repos.d/opensearch-2.x.repo
# Clean yum cache
sudo yum clean all
# Show available repos
sudo yum repolist
# Show available opensearch versions
sudo yum list opensearch --showduplicates
# Install opensearch
sudo yum install -y 'opensearch-2.5.0'

# Start opensearch (it takes some time)
sudo systemctl start opensearch
# Enable it to start automatically
sudo systemctl enable opensearch

# See status
sudo systemctl status opensearch
```

Test that it is working:
```
curl -X GET -u admin:admin --insecure https://localhost:9200
```

Edit the configuration to enable not only local but also external connections:
```
sudo cp /etc/opensearch/opensearch.yml /etc/opensearch/opensearch.yml.bak

sudo vi /etc/opensearch/opensearch.yml
network.host: 0.0.0.0

sudo vi /etc/opensearch/jvm.options
-Xms1g
-Xmx1g

sudo systemctl restart opensearch
```

## Opensearch Dashboards
```
sudo curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.x/opensearch-dashboards-2.x.repo -o /etc/yum.repos.d/opensearch-dashboards-2.x.repo

sudo yum install -y 'opensearch-dashboards-2.5.0' findutils
sudo systemctl start opensearch-dashboards
sudo systemctl enable opensearch-dashboards
```

Test installation:
```
curl -L -X GET http://localhost:5601
```

Enable outside connectivity:
```
sudo cp /etc/opensearch-dashboards/opensearch_dashboards.yml /etc/opensearch-dashboards/opensearch_dashboards.yml.bak
sudo vi /etc/opensearch-dashboards/opensearch_dashboards.yml
server.host: 0.0.0.0

sudo systemctl restart opensearch-dashboards

sudo systemctl status opensearch-dashboards

# Verify with
sudo ss -ltpn
```

Now we want to open the ports in the security group so we can connect from the VPN to opensearch dashboards and opensearch:
- Create a security group called opensearch with tcp ports 5601 (opensearch dashboards), 9200 (opensearch) and 9300 (opensearch internal). 
  You can do it in the web or using the cli
```
openstack security group create opensearch
openstack security group rule create --ethertype IPv4 --protocol tcp --dst-port 5601 --remote-ip 0.0.0.0/0 opensearch
openstack security group rule create --ethertype IPv4 --protocol tcp --dst-port 9200 --remote-ip 0.0.0.0/0 opensearch
openstack security group rule create --ethertype IPv4 --protocol tcp --dst-port 9300 --remote-ip 0.0.0.0/0 opensearch
```
- Associate the new security group to the instance
```
openstack server add security group opensearch-single-node opensearch
```
- Connect to: `http://<ip address>:5601` using credentials `admin:admin`

Just for fun, you can import any of the sample data and visualize them.

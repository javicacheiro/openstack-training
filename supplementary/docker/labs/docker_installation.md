# Docker Installation
Copy the docker.repo file to the instance
```bash
scp docker.repo cesgaxuser@openstack-cli:
```

Install docker and docker-compose:
```bash
sudo cp docker.repo /etc/yum.repos.d
sudo dnf install -y --enablerepo docker docker-ce docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
```


Check that docker is working:
```bash
sudo docker ps
# docker-compose-plugin: it is available as "docker compose" instead of "docker-compose"
sudo docker compose version
```

To allow non-root users to use docker you have to add them to the docker group.
```
sudo usermod --append --groups docker cesgaxuser
```

Now if you logout and login again you will be able to run docker commands from cesgaxuser account:
```
docker ps
```

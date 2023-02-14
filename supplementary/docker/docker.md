# Docker

One of the main advantadges of docker compared to virtual machines is that we have a lot of ready-to-use images already available.

Apart from that it has also several advantadges like:
- It is much more lightweight than virtual machines
- It is much faster
- It is very easy to use

Existing container images are published in what is called a registry, there are different public registries:
- [Dockerhub](https://hub.docker.com/)
- [Quay](https://quay.io/)

Dockerhub is by far the most popular.

You can also deploy a private registry.

## Installing Docker
Lab:
- [Docker installation](labs/docker_installation)

## Using Docker
To look for existing container images you can go to public registries like Docker Hub:
- [Dockerhub](https://hub.docker.com/)

You can search for container images in the web or you can use the CLI.

Search container images:

    docker search alpine

List tags (not supported by CLI):

    # You will need the jq tool (not installed by default) and curl
    sudo dnf -y install jq
    # With page_size you control how many tags are listed
    curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/alpine/tags?page_size=20' | jq '.results[].name'

Download container image:

    docker pull alpine:3.17

Run container interactively based on the downloaded image:

    docker run -ti alpine:3.17 /bin/sh

Delete an image from the local cache:

    docker rmi alpine:3.17

## Running an interactive container
The `-t` flag assigns a pseudo-tty and the `-i` flag grabs STDIN

    docker run -ti alpine:3.17 /bin/bash

To detach the tty without exiting the shell, use the escape sequence

    Ctrl-p + Ctrl-q

This will continue to exist in a stopped state once exited (see `docker ps -a`)

To reconnect to an interactive container use:

    docker attach elegant_mestorf

## Running a daemonized container
The `-d` flag tells Docker to run the container and put it in the background

    docker run -d alpine:3.17 /bin/sh -c "while true; do date; echo hello world; sleep 2; done"

To see its output:

    docker ps
    docker logs <container_name>

To stop and delete it:

    docker stop <container_name>
    docker rm <container_name>

Or we can do both things in a single command:

    docker rm -f <container_name>

## Commands
Run a container from dockerhub:

    docker run -ti centos:7 /bin/bash

List running containers

    docker ps

List running containers and stopped containers (not deleted):

    docker ps -a

See the output of a given container (you can reference it by name)

    docker logs insane_babbage

Show details about a given container

    docker inspect insane_babbage

Execute a command inside a container

    docker exec -ti insane_babbage /bin/bash

Stop a container

    docker stop insane_babbage

Remove a container:

    docker rm instane_babbage

List images:

    docker images

Remove an image:

    docker rmi <image_id>

Restart an existing container after it exited (your changes are still there):

    docker ps -a
    docker start f357e2faab77

Commit changes (to the host local repo)
 - Using container id:
     ```
     docker commit -m="Custom Alpine" --author="Javier Cacheiro" 453a854f5ae4 javicacheiro/alpine:custom
     ```
 - Using container name
     ```
     docker commit -m="Custom Alpine" --author="Javier Cacheiro" my-custom-alpine javicacheiro/alpine:custom
     ```

Build image from Dockerfile

    docker build -t javicacheiro/alpine:custom .

Show the history of an image:

    docker history hadoop/fs02-hadoop

## More about logging
Docker manages the logs of the running containers. Applications that run inside containers should write its logs to `/dev/stdout`, keep in mind that using `/dev/console` does not work. Also programs should avoid using `/dev/log` synce journald is not running.

To see the logs use (equivalent of `tail -f`):

    docker logs -t -f login5

Or you can also see the logs from a given date:

    docker docker logs -t --since=2022-09-02T09:56 login5

## Docker Compose
Docker Compose allows to run deployments with multiple containers defined in a `docker-compose.yml` file.

To start a `docker-compose.yml` go to the directory where it is located and run:

    docker compose up -d

this will automatically run in detached mode all the containers defined in the file.

To see the logs:

    docker compose logs

To stop all the containers in the file:

    docker compose stop

NOTE: New versions of Docker include the functionality of the standalone `docker-compose` utility inside the docker cli as a docker plugin. The only difference is that now you will use `docker compose` instead of `docker-compose`.

## Creating your own container images
### Creating our own image interactively
This is always a good starting point to experiment with the installation:

For example in this case we will create an alpine image that includes the `jq` tool.

Start the container:

    docker run -ti alpine:3.17.2 /bin/sh

We can see that jq is not installed by default in the alpine image.
```
/ # jq
/bin/sh: jq: not found
```

Install/configure all that is needed:

    apk update
    apk add jq

Clean what is not needed and exit:

    rm -rf /var/cache/apk/*
    rm /root/.ash_history
    exit

Look for the container ID, we have to use the `-a` option to see stopped containers:

    docker ps -a

Commit changes:

    docker commit -m="Alpine with jq" --author="Javier Cacheiro" a1d5277534f9 javicacheiro/alpine:3.17.2-jq-test

Login to docker hub:

    docker login

Publish the image:

    docker push javicacheiro/alpine:3.17.2-jq-test

### Creating our own image using a Dockerfile
Once you know which commands you have to run to install your application, the image creation procedure can be automated using a `Dockerfile`. This is the recommended way to keep track of how the container was built so it can be later updated.

First we create a `Dockerfile` with the commands needed:

```
FROM alpine:3.17.2
MAINTAINER Javier Cacheiro <javier.cacheiro.lopez@cesga.gal>

RUN apk update \
 && apk add jq \
 && rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/bin/jq"]
CMD ["--help"]
```

Now we build the image:

    docker build -t javicacheiro/alpine:3.17.2-jq .

Publish the image:

    docker push javicacheiro/alpine:3.17.2-jq

## CMD vs ENTRYPOINT
Usually the Dockerfile will end with a `CMD` or `ENTRYPOINT` instruction.

`CMD` is used for containers that run a service. It contains the executable as well as the arguments needed to start the service. For example this is the `CMD` used to start nginx in the official image:
```
CMD ["nginx", "-g", "daemon off;"]
```

Another commonly used option is, insted of calling the program directly, to provide a script:
```
CMD ["/start.sh"]
```
This is more flexible and allows better customization.


Another common use case is when, instead of creating a container for a service, you want to create a container for a tool. In this case you will use `ENTRYPOINT` instead of `CMD`.

This allows the container to run as if it was the command (and then you can also use CMD as the default arguments).

For example in our example we have:

```
ENTRYPOINT ["/usr/bin/jq"]
CMD ["--help"]
```

### Publishing the image
Login to docker hub:

    docker login

Tag the image:

    docker tag <imageID> javicacheiro/alpine:custom

Push an image to docker hub:

    docker push javicacheiro/alpine:custom

Retrieve an image from our account in docker hub:

    docker pull javicacheiro/alpine:custom

To delete it from Docker Hub repository we have to sign in and use the "Delete repository" link.

## Advanced Networking
Reference: https://docs.docker.com/articles/networking/

### Using the same network interfaces and addresses as the host
Running the VM using the same network interfaces as the host machine:

    docker run --net=host ...

### Adding a static IP with pipework
We can use [pipework](https://github.com/jpetazzo/pipework) to add an IP to the container after it is running:

    pipework <hostinterface> [-i containerinterface] [-l localinterfacename] <guest> <ipaddr>/<subnet>[@default_gateway] [macaddr][@vlan]

    docker run --net="none" ...
    pipework virbrPRIVATE -i eth1 networktest 10.112.248.102/16@10.112.0.1
    pipework virbrSTORAGE -i eth2 networktest 10.117.248.102/16

When using `pipework` we have to keep in mind that newer docker versions automatically change the default policy of the iptables FORWARD chain to DROP. This prevents inter-host communication so we have to change it back to ACCEPT.

To fix it we have to change back the default policy:

    iptables -P FORWARD ACCEPT

## Running in privileged mode
Sometimes you may need to run a container in privileged mode so it has direct access to some devices:

    docker run --privileged -v /dev/infiniband:/dev/infiniband -i -t alcachi/centos6:infiniband /bin/bash

## Custom /etc/hosts
`/etc/hosts` is automatically overwritten when the container is started so if you try to overrite with an `ADD`
command the changes will be lost.

The right way to do it is adding them through the `--add-host` command line option:

    docker run --add-host=hostname:ip

## Custom /etc/resolv.conf
As `/etc/hosts`, `/etc/resolv.conf` is overritten on boot and it copies the version of the file from the main host.

To create a custom resolv.conf use the following options of docker run:

    --dns-search  Set custom DNS search domains
    --dns         Set custom DNS servers

## Cleaning stopped containers

    docker rm $(docker ps --filter "status=exited" -q)

## Cleaning unused images

    docker rmi $(docker images |grep none|awk '{print $3}')

## Truncate logs
Logs are stored in json format in `/var/lib/docker/containers/`. The directory name starts with the container id.

Logs can get very very big.

So it is a good idea to set a process that truncates them periodically (like logrotate does with standard logs):

```
cd /var/lib/docker/containers/8f8e60c96938314aead95a06bf0b36ef1972d950f856c847930e41f12ec05dcd
truncate -s 1M 8f8e60c96938314aead95a06bf0b36ef1972d950f856c847930e41f12ec05dcd-json.log
```

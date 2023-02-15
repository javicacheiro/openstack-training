# Running a Private Registry
## Run a local registry for testing
Running a local registry for testing purposes is very easy, we can use docker to run it:
```
docker run -d -p 5000:5000 --name registry registry:2
```

This will create the container registry listening in port 5000 and it will redirect the host port 5000 to this port.

If needed we will have also to update the instace security group configuration to allow ingress traffic to this port.

## Test it
First we download a image from docker hub:
```
docker pull alpine:3.14
```

Now we have to tag with the location of our local registry:
```
docker tag alpine:3.14 localhost:5000/alpine:3.14
```

Finally we can publish the image in our local registry:
```
docker push localhost:5000/alpine:3.14
```

From now on we can download the image from our registry instead of docker hub using:
```
docker pull localhost:5000/alpine:3.14
```

## External clients
Since we are using a very insecure registry to use it from external clients (outside localhost) we have to add the following configuration in the clients:

/etc/docker/daemon.json 
```
{
    "insecure-registries": [
        "10.38.28.219:5000"
    ]
}
```

Then we have to restart docker in the client:
```
sudo systemctl restart docker
```
 
## Final notes
For production you should use:
- A `data` volume
- TLS encryption (requires a certificate)

This requires to register the server in DNS and to request a TLS certificate so it is outside of the scope of this lab.

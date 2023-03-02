# Running Redis
In this lab we will install and run the popular Redis database using a docker container.

In this case we will start the container with the `-d` option so it will run in the backgroud (daemonized):

    docker run -p 6379:6379 --name redis1 -d redis

We can see that it is running with:

    docker ps

Now we can run the `redis-cli` client and test our new Redis server. We can install the redis-cli tool or run it using also a container.

    docker run --net host -ti --rm redis redis-cli -h localhost

and you can type some commands to test the new redis server:

    # List existing keys
    keys *
    # Create a new key
    set mykey myvalue
    # Get my new key
    get mykey
    # Create a new key
    set mykey2 myvalue2
    # List existing keys
    keys *
    # Exit
    quit

Finally, once we have tested the Redis server, since we will not be using it any more we can remove it to free resources:

    docker rm -f redis1


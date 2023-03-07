# ClusterShell
[ClusterShell](https://github.com/cea-hpc/clustershell) is a **distributed shell** developed by CEA that allows to run commands across a set of servers.

It is very useful to manage a server farm or in our case a group of virtual machines.

ClusterShell uses SSH to connect to the servers, so that we can directly use it with the key pair configured in the cloud instances.

## Notation
A set of nodes can be specified using a range, eg. `node-[1-3]` means node-1, node-2 and node-3.

We can always verify how a node range will be expanded using the `nodeset` utility:
```
>> nodeset -e node-[1-3,5,8-10,15]
node-1 node-2 node-3 node-5 node-8 node-9 node-10 node-15
>> nodeset -e n[07-12]
n07 n08 n09 n10 n11 n12
```

## Basic usage
Run a command in nodes `node-[1-3]`:
```
clush -l cesgaxuser -bw node-[1-3] echo OK
```

Copy a file to a set of nodes:
```
clush -l cesgaxuser -bw node-[1-3] --copy docker.repo --dest /tmp
```

The `-b` option takes care of grouping the outputs (very useful when working with a lot of nodes).

## Defining groups
We can define groups of nodes using the `/etc/clustershell/groups` file:
```
all: @mngt,@lustre,@compute

mngt: mngt0-[1-2]

lustre: @oss,@mds
oss: oss[6701-6702,6801-6802]
mds: mds[6801-6802]

compute: c[6601-6648,6714,6901-6948]
```

Then we can run a command in a specific group using:
```
clush -l cesgaxuser -bw @compute echo OK
```

## Labs
- [Installing ClusterShell](clush_installation.md)
- [Installing Opensearch in cluster mode](labs/installing_opensearch_kibana_and_logstash_cluster-mode.md)

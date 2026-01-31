# OpenStack RESTful API

We can also use the OpenStack RESTful API directly.

## Endpoints
Take into account that each service has a specific endpoint which is associated to a different port.

Below you can see the URL that you have to use for each service (to get this information from the cli you would need admin privileges):
```
openstack endpoint list | grep public
[root@controller(c27-34) ~]# openstack endpoint list --interface public
+----------------------------------+-----------+--------------+----------------+---------+-----------+--------------------------------------------------+
| ID                               | Region    | Service Name | Service Type   | Enabled | Interface | URL                                              |
+----------------------------------+-----------+--------------+----------------+---------+-----------+--------------------------------------------------+
| 334f0ae41bc24b2397fd2245495e1631 | RegionOne | placement    | placement      | True    | public    | https://cloud.srv.cesga.es:8780                  |
| 3bd1db00df824f52b96c8c1a4e0c9966 | RegionOne | keystone     | identity       | True    | public    | https://cloud.srv.cesga.es:5000                  |
| 5af5941445e34aadbdfce88ec7d88a12 | RegionOne | heat-cfn     | cloudformation | True    | public    | https://cloud.srv.cesga.es:8000/v1               |
| 81142b29c0dd4b37a0af00b733611e1e | RegionOne | gnocchi      | metric         | True    | public    | https://cloud.srv.cesga.es:8041                  |
| 81a556c2d6f04b43916846d7aba14b15 | RegionOne | glance       | image          | True    | public    | https://cloud.srv.cesga.es:9292                  |
| 81a6810a301543cc8021a1873e4579ba | RegionOne | manilav2     | sharev2        | True    | public    | https://cloud.srv.cesga.es:8786/v2               |
| a68bf4931194432998b11334b56a7a51 | RegionOne | heat         | orchestration  | True    | public    | https://cloud.srv.cesga.es:8004/v1/%(tenant_id)s |
| a766e1dfb9aa4317aa5daf61359c83ab | RegionOne | nova_legacy  | compute_legacy | True    | public    | https://cloud.srv.cesga.es:8774/v2/%(tenant_id)s |
| aea4ba1a182b44b1982790ac3d69890a | RegionOne | manila       | share          | True    | public    | https://cloud.srv.cesga.es:8786/v1/%(tenant_id)s |
| ba5fb33ae06340c3912e127474bcb12d | RegionOne | cinderv3     | volumev3       | True    | public    | https://cloud.srv.cesga.es:8776/v3/%(tenant_id)s |
| ba7fbf56506a4192b6b969b8f6a189c7 | RegionOne | nova         | compute        | True    | public    | https://cloud.srv.cesga.es:8774/v2.1             |
| d1ee1228b30742ba821fe864ea0f45ac | RegionOne | neutron      | network        | True    | public    | https://cloud.srv.cesga.es:9696                  |
+----------------------------------+-----------+--------------+----------------+---------+-----------+--------------------------------------------------+
```

Each endpoint has internal, admin and public interfaces. In our case we are interested in the "public" interface.

## Authentication: Obtaining a token
First we need to obtain a token from keystone so we can then use it to authenticate our requests to the given service endpoints.

In general we are interested in creating a project-scoped token (ie. a token to access your project).

One way to obtain the token is to first source your rc-file so it will load the required variables in the environment:
```bash
source bigdata-openrc.sh
```

Then you can use the following code to obtain the token:
```bash
# Create the JSON request body
REQUEST_BODY=$(cat <<EOF
{
  "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "$OS_USERNAME",
          "domain": {
            "name": "$OS_USER_DOMAIN_NAME"
          },
          "password": "$OS_PASSWORD"
        }
      }
    },
    "scope": {
      "project": {
        "name": "$OS_PROJECT_NAME",
        "domain": {
          "name": "$OS_PROJECT_DOMAIN_ID"
        }
      }
    }
  }
}
EOF
)

RESPONSE_HEADERS=$(curl -sSL -D - -X POST -H "Content-Type: application/json" -d "$REQUEST_BODY" "$OS_AUTH_URL/v3/auth/tokens" -o /dev/null)

# The token is returned in the "x-subject-token" header
TOKEN=$(echo "$RESPONSE_HEADERS" | awk -v IGNORECASE=1 '/x-subject-token/ {print $2}' | tr -d '\r')

echo "Token: $TOKEN"
```

NOTE: Do not name the token "OS_TOKEN" because it will interfere with the openstack-cli.

To simplify the token generation process you can use the `labs/get_keystone_token.sh` helper script together with your openstack rc-file.
```
source bigdata-openrc.sh
source get_keystone_token.sh
```

This will load the token in the `TOKEN` environmental variable that you will later provide this TOKEN as the `X-Auth-Token` header of the request.

## List available images
```
curl -s -H "X-Auth-Token: $TOKEN" -X GET -H "Accept: application/json" https://cloud.srv.cesga.es:9292/v2/images | python3 -m json.tool
```

## List flavors
```
curl -s -H "X-Auth-Token: $TOKEN" -X GET -H "Accept: application/json" https://cloud.srv.cesga.es:8774/v2.1/flavors/detail | python3 -m json.tool
```

## List running servers
To list the running servers in your project use:
```
curl -s -H "X-Auth-Token: $TOKEN" -X GET -H "Accept: application/json" https://cloud.srv.cesga.es:8774/v2.1/servers/detail | python3 -m json.tool
```

## List available metrics
List available metrics in gnocchi:
```
curl -s -H "X-Auth-Token: $TOKEN" -X GET -H "Accept: application/json" https://cloud.srv.cesga.es:8041/v1/metric | python3 -m json.tool
```

## Metric status
```
http://10.108.0.111:8041/v1/status
```


## Looking for examples
It is very useful to use the `--debug` option of the `openstack-cli` to get information about the queries needed to get certain information.
In the output it will include the requests made, the equivalent curl commands needed, and the json outputs:
```
openstack image list --debug
```

For example to see the curl commands equivalent to the requests made by a given openstack-cli command:
```
openstack image list --debug 2>&1 | grep ^REQ
```

## Tracking your requests
As a result of your request you will get a status code. 2xx codes mean the request was accepted but it does not always mean that the action you requested has sucesfully completed.

For that reason you can track requests by request ID:
- Local request ID: Locally generated unique request ID by each service and different between all services (Nova, Cinder, Glance, Neutron, etc.) involved in that operation. The format is req- + UUID (UUID4).
- Global request ID: User specified request ID which is utilized as common identifier by all services (Nova, Cinder, Glance, Neutron, etc.) involved in that operation. This request ID is same among all services involved in that operation. The format is req- + UUID (UUID4).

The global request ID is especially useful to trace information in the logs in ElasticSearch/OpenSearch.

To specify it you have to include it in each REST API request in the `X-Openstack-Request-Id` header.

## References
- [Compute API](https://docs.openstack.org/api-ref/compute/)
- [Tracking requests and Faults](https://docs.openstack.org/api-guide/compute/faults.html)
- [Keystone API Examples using Curl](https://docs.openstack.org/keystone/pike/api_curl_examples.html)

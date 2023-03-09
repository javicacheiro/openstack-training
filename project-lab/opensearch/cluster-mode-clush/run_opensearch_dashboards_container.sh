#!/bin/bash
#
# Script to start opensearch dashboards
#

NAME="dashboards"

# Name of the docker image to use
VERSION="2.6.0"
IMAGE="opensearchproject/opensearch-dashboards:$VERSION"

# Mappings
declare -A ADDRESS
ADDRESS["opensearch-1"]="10.38.28.237"
ADDRESS["opensearch-2"]="10.38.27.170"
ADDRESS["opensearch-3"]="10.38.28.8"
ADDRESS["dashboards"]="10.38.29.17"

# Docker custom options
OPTS+=" -d "
OPTS+=" --restart=unless-stopped "
#OPTS+=" --privileged"
OPTS+=" --net=host"
#OPTS+=" -v /sys/fs/cgroup:/sys/fs/cgroup:ro"
OPTS+=" --add-host=opensearch-1:${ADDRESS['opensearch-1']}"
OPTS+=" --add-host=opensearch-2:${ADDRESS['opensearch-2']}"
OPTS+=" --add-host=opensearch-3:${ADDRESS['opensearch-3']}"
OPTS+=" --add-host=dashboards:${ADDRESS['dashboards']}"
OPTS+=" -e DOCKER_FIX=''"
#OPTS+=" -e OPENSEARCH_HOSTS=https://${ADDRESS['elk1']}:9200,https://${ADDRESS['elk2']}:9200,https://${ADDRESS['elk3']}:9200,https://${ADDRESS['elk4']}:9200"
OPTS+=" -e OPENSEARCH_HOSTS=https://opensearch-1:9200"

# Run docker
echo "Starting docker container: $NAME"
# Start from a fresh container
docker run $OPTS $VOLUMES -h $NAME --name ${NAME} $IMAGE

echo "Done"

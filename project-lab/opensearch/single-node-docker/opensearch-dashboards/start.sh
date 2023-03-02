#!/bin/sh

OPTS="$OPTS"
if [ -n "$OPENSEARCH_HOSTS" ]; then
    OPTS+=" --opensearch.hosts='["http://opensearch:9200"]'"
fi

/usr/share/opensearch-dashboards/bin/opensearch-dashboards $OPTS

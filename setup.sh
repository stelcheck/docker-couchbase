#!/usr/bin/env bash

/etc/init.d/couchbase-server start
while ! curl -s -o /dev/null 'http://localhost:8091'
do 
  sleep 1
done

if 
  [ -n "${CLUSTER_ACTION}" ]
then
  echo "CLUSTER_ACTION = ${CLUSTER_ACTION}"
  case ${CLUSTER_ACTION} in
    INIT_CLUSTER)
        echo "INIT_CLUSTER"
        couchbase-cli cluster-init \
            --user=${CLUSTER_ADMIN_NAME} \
            --password=${CLUSTER_ADMIN_PASSWORD} \
            --cluster-init-ramsize=${CLUSTER_RAM_SIZE} \
            --cluster-index-ramsize=${CLUSTER_INDEX_RAM_SIZE:-512} \
            --cluster-fts-ramsize=${CLUSTER_FTS_RAM_SIZE:-256} \
            --services=${CLUSTER_SERVICES}
        ;;
    ADD_TO_CLUSTER)
        echo "ADD_TO_CLUSTER"
        couchbase-cli rebalance \
            --cluster=${CLUSTER_HOST_NAME}:${CLUSTER_HOST_PORT} \
            --user=${CLUSTER_ADMIN_NAME} \
            --password=${CLUSTER_ADMIN_PASSWORD} \
            --server-add=$(hostname):8091 \
            --server-add-username=${CLUSTER_ADMIN_NAME} \
            --server-add-password=${CLUSTER_ADMIN_PASSWORD} \
            --services=${CLUSTER_SERVICES}
        ;;
    esac
fi

ps aux

touch /tmp/test
exec tail -f /tmp/test # /opt/couchbase/var/lib/couchbase/logs/*
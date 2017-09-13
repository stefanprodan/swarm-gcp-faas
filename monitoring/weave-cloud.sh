#!/usr/bin/env bash

set -e

#export DOCKER_HOST=$(terraform output swarm_manager_ip)

if [ "$1" == "rm" ]; then
    docker stack rm weave
    sleep 5
    docker volume prune -f
else
    network="monitoring"
    if [ ! "$(docker network ls --filter name=$network -q)" ];then
        docker network create --attachable -d overlay  $network
    fi

    TOKEN=rh1dj7xbehb6zu1gynm9fjd1t65fhnqp \
    ADMIN_USER=admin \
    ADMIN_PASSWORD=admin \
    docker stack deploy -c weave-cloud.yml weave
fi

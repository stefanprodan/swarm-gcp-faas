#!/usr/bin/env bash

set -e

#export DOCKER_HOST=$(terraform output swarm_manager_ip)

if [ "$1" == "rm" ]; then
    docker stack rm app
    docker stack rm mongo
else
    if [ ! "$(docker network ls --filter name=mongo -q)" ];then
        docker network create --attachable -d overlay mongo
    fi
    if [ ! "$(docker network ls --filter name=mongos -q)" ];then
        docker network create --attachable -d overlay mongos
    fi

    echo ">>> Deploying MongoDB sharded cluster"
    docker stack deploy -c mongo-cluster.yml mongo

    echo && echo ">>> Waiting for MongoDB cluster bootstrap to finish"
    while true; do
        curl -sS http://${DOCKER_HOST}:9090 2>/dev/null && break
        sleep 1
    done

    echo && echo ">>> MongoDB cluster is ready, deploying load test app"
    docker stack deploy -c mongo-loadtest.yml app

    echo && echo ">>> Running load test with 100K read/write operations"
    go get -u github.com/rakyll/hey
    sleep 5
    hey -n 100000 -c 100 -m GET http://${DOCKER_HOST}:9990/
fi

#!/usr/bin/env bash

set -e

eval "$(jq -r '@sh "HOST=\(.host) USER=\(.user)"')"

MANAGER=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$HOST sudo docker swarm join-token manager -q)

WORKER=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$HOST sudo docker swarm join-token worker -q)

jq -n --arg manager "$MANAGER" --arg worker "$WORKER" \
    '{"manager":$manager,"worker":$worker}'

#!/bin/bash
set -euo pipefail


docker info > /dev/null 2>&1 || {
  echo "[kafka_network] Docker is not running"
  exit 1
}


NETWORK=staynest-kafka-net1
if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
  echo "[kafka_network] Creating docker network $NETWORK..."
  docker network create "$NETWORK"
  echo "[kafka_network] Network $NETWORK Created"
else
  echo "[kafka_network] Network $NETWORK already exists"
fi
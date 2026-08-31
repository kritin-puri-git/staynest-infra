#!/bin/bash
set -euo pipefail


docker info > /dev/null 2>&1 || {
  echo "[mongo_network] Docker is not running"
  exit 1
}


NETWORK=staynest-mongo-net1
if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
  echo "[mongo_network] Creating docker network $NETWORK..."
  docker network create "$NETWORK"
  echo "[mongo_network] Network $NETWORK Created"
else
  echo "[mongo_network] Network $NETWORK already exists"
fi
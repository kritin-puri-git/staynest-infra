#!/bin/bash
set -euo pipefail


docker info > /dev/null 2>&1 || {
  echo "[mysql_network] Docker is not running"
  exit 1
}


NETWORK=staynest-mysql-net1
if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
  echo "[mysql_network] Creating docker network $NETWORK..."
  docker network create "$NETWORK"
  echo "[mysql_network] Network $NETWORK Created"
else
  echo "[mysql_network] Network $NETWORK already exists"
fi

sleep 5
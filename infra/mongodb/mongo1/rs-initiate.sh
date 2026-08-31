#!/bin/bash
set -euo pipefail

set -a
source .env
set +a

error() {
  echo "$1"
  exit 1
}

mongo_exec() {
  docker exec staynest-mongo-1 mongosh -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin "$@"
}

PING_MAX_RETRIES=30
COUNT=0

echo "[rs-initiate] Checking Mongodb Connection ..."

until mongo_exec --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  COUNT=$((COUNT+1))

  if (( COUNT >= PING_MAX_RETRIES ));then
    error "[rs-initiate] Mongodb Unreachable after $COUNT attempts, Exiting"
  fi
  echo "[rs-initiate] Mongodb not ready, Retry $COUNT/$PING_MAX_RETRIES...."
  sleep 2
done

echo "[rs-initiate] Mongodb Connected"

REPLICA_SET_EXIST="$( mongo_exec --quiet --eval "try{ rs.status().ok } catch(e) { 0 }" | tr -d '\r\n' )"

if [[ $REPLICA_SET_EXIST != "1" ]]; then
  echo "[rs-initiate] ReplicaSet not initialized. Initializing ... "

  mongo_exec --eval '
    rs.initiate({
      _id:"rs0",
      members: [
        {_id:0, host: "staynest-mongo-1:27017"}
        ]
    })'

    sleep 5

  echo "[rs-initiate] ReplicaSet Initiated successfully."
else
  echo "[rs-initiate]ReplicaSet already initialized"
fi
MAX_RETRIES=30
PRIMARY_COUNT=0
until [[ "$( mongo_exec --quiet --eval "db.hello().isWritablePrimary" | tr -d '\r\n' )" == "true" ]]; do
  PRIMARY_COUNT=$((PRIMARY_COUNT+1))

    if (( PRIMARY_COUNT >= MAX_RETRIES ));then
      error "[rs-initiate] Node not elected Primary after $PRIMARY_COUNT attempts, Exiting"
    fi
    echo "[rs-initiate] Waiting for Primary, Retry $PRIMARY_COUNT/$MAX_RETRIES...."
    sleep 2
done

echo "Node elected for Primary"


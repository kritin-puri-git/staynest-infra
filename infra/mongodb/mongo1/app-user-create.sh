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

MAX_RETRIES=30
PRIMARY_COUNT=0
until [[ "$( mongo_exec --quiet --eval "db.hello().isWritablePrimary" | tr -d '\r\n' )" == "true" ]]; do
  PRIMARY_COUNT=$((PRIMARY_COUNT+1))

    if (( PRIMARY_COUNT >= MAX_RETRIES ));then
      error "[app-user-create] Node not elected Primary after $PRIMARY_COUNT attempts, Exiting"
    fi
    echo "[app-user-create] Waiting for Primary, Retry $PRIMARY_COUNT/$MAX_RETRIES...."
    sleep 2
done


USER_EXISTS="$( mongo_exec --quiet --eval "db.getSiblingDB('$MONGO_STAYNEST_USER_DATABASE').getUser('$MONGO_STAYNEST_USER_USERNAME') ? 1 : 0" | tr -d '\r\n' )"

if [[ "$USER_EXISTS" == "0" ]]; then
  echo "[app-user-create] Creating User..."

  mongo_exec --eval "
  db.getSiblingDB('$MONGO_STAYNEST_USER_DATABASE').createUser({
    user: '$MONGO_STAYNEST_USER_USERNAME',
    pwd: '$MONGO_STAYNEST_USER_PASSWORD',
    roles: [
      { role: 'readWrite', db: '$MONGO_STAYNEST_USER_DATABASE' }
    ]
  })
  "
  echo "[app-user-create] App user created successfully"
else
  echo "[app-user-create] User already exists"
fi








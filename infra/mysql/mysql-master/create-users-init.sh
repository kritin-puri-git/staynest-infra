#!/bin/bash

set -euo pipefail

COUNT=0
MAX_RETRIES=30
until mysqladmin ping -h "localhost" -u root -p"$MYSQL_ROOT_PASSWORD" --silent;do
  COUNT=$((COUNT+1))

  if (( COUNT >= MAX_RETRIES )); then
      echo "[create-user-init] MYSQL did not become ready after $MAX_RETRIES attempts"
      exit 1
  fi

  echo "[create-user-init] MYSQL not ready yet ... ($COUNT)"
  sleep 2
done

echo "[create-user-init] MYSQL is up"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOF
CREATE USER IF NOT EXISTS 'replica'@'%' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
EOF

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOF
CREATE DATABASE IF NOT EXISTS staynest;
EOF

echo "[create-user-init] replica user and staynest DB ready"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOF
CREATE USER IF NOT EXISTS 'staynest_master'@'%' IDENTIFIED BY 'writerpass';
GRANT ALL PRIVILEGES ON staynest.* TO 'staynest_master'@'%';

EOF
echo "[create-user-init] staynest master user ready"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOF

CREATE USER IF NOT EXISTS 'staynest_replica'@'%' IDENTIFIED BY 'readerpass';
GRANT SELECT ON staynest.* TO 'staynest_replica'@'%';

EOF
echo "[create-user-init] staynest replica user ready"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOF

CREATE USER IF NOT EXISTS 'staynest_debezium'@'%' IDENTIFIED BY 'connectorpass';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT
ON *.* TO 'staynest_debezium'@'%';

EOF
echo "[create-user-init] Debezium user ready"


mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOF

FLUSH PRIVILEGES;

EOF



echo "[create-user-init] create-user-init.sh completed successfully"
sleep 2
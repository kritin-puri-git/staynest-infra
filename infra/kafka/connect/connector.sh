#!/bin/bash

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "staynest-mysql-connector",
    "config": {

      "connector.class": "io.debezium.connector.mysql.MySqlConnector",

      "database.hostname": "host.docker.internal",
      "database.port": "3307",

      "database.user": "staynest_debezium",
      "database.password": "connectorpass",

      "database.server.id": "100",
      "topic.prefix": "staynest",

      "table.include.list": "staynest.users",

      "schema.history.internal.kafka.bootstrap.servers": "staynest-kafka:29092",
      "schema.history.internal.kafka.topic": "schema-history.staynest",

      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false"
    }
  }'


  sleep 10
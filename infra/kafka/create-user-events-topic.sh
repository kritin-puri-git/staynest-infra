#!/bin/bash

docker exec -it staynest-kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server staynest-kafka:29092 --create --if-not-exists --topic user-events \
  --partitions 3 --replication-factor 1

sleep 5

docker exec -it staynest-kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server staynest-kafka:29092 --list

sleep 10
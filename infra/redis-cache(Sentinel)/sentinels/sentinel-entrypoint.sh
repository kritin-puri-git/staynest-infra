#!/bin/sh

set -eu

REDIS_PASSWORD=$(cat /run/secrets/redis_password)

if [ ! -f /etc/redis/sentinel.conf ]; then
  cat <<EOF > /etc/redis/sentinel.conf
  port 26379
  sentinel monitor mymaster staynest-redis-cache-master 6379 2
  sentinel auth-user mymaster default
  sentinel auth-pass mymaster ${REDIS_PASSWORD}

  sentinel down-after-milliseconds mymaster 15000
  sentinel parallel-syncs mymaster 1
  sentinel failover-timeout mymaster 20000
EOF
fi

exec redis-sentinel /etc/redis/sentinel.conf
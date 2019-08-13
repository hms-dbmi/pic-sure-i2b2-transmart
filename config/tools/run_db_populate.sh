#!/bin/sh

docker run --rm -it \
  --env-file /tmp/local.secrets \
  --volume $PWD:/var/tmp \
  python /var/tmp/db_populate.sh

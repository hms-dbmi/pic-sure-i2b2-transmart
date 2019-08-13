#!/bin/sh

# This is just a temporary example, showing how to run the init_db.sh
# script via Docker. Will need a simple secrets file, with the mysql
# connection parameters filled in.

docker run -it --rm \
  --env-file /tmp/local.secrets \
  --volume ${PWD}:/var/tmp \
  mysql sh -c /var/tmp/db_seed.sh

#!/bin/sh

# This is just a temporary example, showing how to run the init_db.sh
# script via Docker. Will need a simple secrets file, with the mysql
# connection parameters filled in.

docker run -it --rm --user=root \
  --volume /home/centos/pic-sure-i2b2-transmart/config/tools:/var/tmp/tools \
  --volume /usr/local/docker-config/db:/root/dbconfig \
  mysql sh -c /var/tmp/tools/db_seed.sh

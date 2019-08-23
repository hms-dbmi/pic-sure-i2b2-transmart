#!/bin/sh

# This is just a temporary example, showing how 
# to run the database population script via Docker.
#
# Using the database connection files from 
# `${CONFIG_DIR}/db/login_config.*` 
# Also, assuming, that the repo is cloned into
# `/home/centos/pic-sure-i2b2-transmart directory`

docker run -it --rm --user=root \
  --volume /home/centos/pic-sure-i2b2-transmart/config/tools:/var/tmp/tools \
  --volume /usr/local/docker-config/db:/root/dbconfig \
  mysql sh -c /var/tmp/tools/db_populate.sh

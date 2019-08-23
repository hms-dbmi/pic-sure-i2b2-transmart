#!/bin/sh

# This is just a temporary example, showing how 
# to run the database population script via Docker.
#
# Using the database connection files from 
# `${CONFIG_DIR}/db/login_config.*` 
# Also, assuming, that the repo is cloned into
# `/home/centos/pic-sure-i2b2-transmart directory`

docker run --rm --user=root \
  --volume ${PWD}/config/tools:/var/tmp/tools \
  --volume /usr/local/docker-config:/var/tmp/config \
  python sh -c /var/tmp/tools/db_populate.sh

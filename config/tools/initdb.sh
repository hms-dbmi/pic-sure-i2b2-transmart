#!/bin/sh

#
# If you need to reset the database, from the EC2, where the configuration files
# are stored. You can run this script.
#
export RDS_MYSQL_HOST=`grep connection-url /usr/local/docker-config/irct/standalone.xml | tail -1 | cut -d "/" -f 3 | cut -d ":" -f 1`
export RDS_MYSQL_PASSWORD=`grep password /usr/local/docker-config/wildfly/standalone.xml  | head -3 | tail -1 | cut -d ">" -f 2  | cut -d "<" -f 1`

docker build \
  --rm \
  --pull \
  --tag mysqlinitdb \
  --build-arg RDS_MYSQL_HOST \
  --build-arg RDS_MYSQL_PASSWORD \
  --file Dockerfile.initdb .


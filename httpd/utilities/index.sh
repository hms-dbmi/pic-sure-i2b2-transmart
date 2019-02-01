#!/bin/bash -x

TMPDIR=/tmp
CWD=`pwd`

source .env

docker system info > ${TMPDIR}/info.txt
export DOCKER_MACHINE_NAME=`egrep -e "^Name: " ${TMPDIR}/info.txt | cut -d" " -f 2`
export DOCKER_VERSION=`docker --version`
export DOCKER_SERVICES_LIST=`docker ps --format '<tr><td>'{{.Names}}'</td><td>'{{.Image}}'</td></tr>' | sort`
export STACK_NAME=$STACK_NAME # Don't ask. Stupid. But we need it!
CONTAINER_NAME=`docker ps --format {{.Names}} | grep httpd`
docker exec ${CONTAINER_NAME} printenv > ${TMPDIR}/index.txt

python \
  ${CWD}/httpd/utilities/index.py \
  local ${CWD}/config/httpd/htdocs \
  /index.html > ${TMPDIR}/index.html

docker cp ${TMPDIR}/index.html ${CONTAINER_NAME}:/usr/local/apache2/htdocs/index.html
rm -f ${TMPDIR}/index.html ${TMPDIR}/index.txt ${TMPDIR}/info.txt

#!/bin/bash -x

dcom_stop() {
  docker-compose --file ../docker-compose.yml stop $1
}

export DOCKER_VERSION=`docker --version`
CONTAINER_NAME=`docker ps --format {{.Names}} | grep httpd`
docker exec ${CONTAINER_NAME} printenv > index.txt
python index.py > index.html
docker cp index.html ${CONTAINER_NAME}:/usr/local/apache2/htdocs/index.html
rm -f index.html
rm -f index.txt

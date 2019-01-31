#!/bin/bash -x

docker system info > info.txt
export DOCKER_MACHINE_NAME=`egrep -e "^Name: " info.txt | cut -d" " -f 2`
export DOCKER_VERSION=`docker --version`
export DOCKER_SERVICES_LIST=`docker ps --format '<tr><td>'{{.Names}}'</td><td>'{{.Image}}'</td></tr>' | sort`

CONTAINER_NAME=`docker ps --format {{.Names}} | grep httpd`
docker exec ${CONTAINER_NAME} printenv > index.txt

python index.py > index.html

docker cp index.html ${CONTAINER_NAME}:/usr/local/apache2/htdocs/index.html
rm -f index.html index.txt info.txt

#!/bin/sh

# docker run --rm --volume /usr/local/docker-config:/tmp/config --volume ${PWD}/config/tools:/tmp/setup alpine /tmp/setup/setup.sh

apk add mysql-client
apk add curl
/tmp/setup/db_seed.sh

apk add python3
pip3 install --upgrade pip
pip3 install pymysql
pip3 install PyJWT
pip3 install requests

export PSAMA_CLIENT_SECRET=`grep 'java:global/client_secret' /tmp/config/wildfly/standalone.xml | cut -d '"' -f 4`
echo "PSAMA_CLIENT_SECRET is ${PSAMA_CLIENT_SECRET}"
python3 /tmp/setup/db_populate.py

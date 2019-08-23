#!/bin/sh

pip3 install pymysql >/dev/null 2>&1
pip3 install PyJWT >/dev/null 2>&1
pip3 install requests >/dev/null 2>&1

export PSAMA_CLIENT_SECRET=`grep "java:global/client_secret" /var/tmp/config/wildfly/standalone.xml | cut -d '"' -f 4`

python3 /var/tmp/tools/db_populate.py

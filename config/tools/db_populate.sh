#!/bin/sh

pip install pymysql
cat <<EOT > /tmp/tmpfile.py
import pymysql

#database connection
connection = pymysql.connect(host="${PSAMA_DB_HOST}",user="${PSAMA_DB_USER}",passwd="${PSAMA_DB_PASSWORD}",database="auth" )
cursor = connection.cursor()

retrive = "SELECT * FROM user WHERE email = '${PSAMA_ROBOT_USER_EMAIL}';"

#executing the quires
cursor.execute(retrive)
rows = cursor.fetchall()
for row in rows:
   print(row)

#commiting the connection then closing it.
connection.commit()
connection.close()
EOT
AUTOMATA_USER_EMAIL=$(python /tmp/tmpfile.py)

pip install PyJWT >/dev/null 2>&1
pip install requests >/dev/null 2>&1
cat <<EOT > /tmp/tmp_getToken.py
import requests
import sys,os
import base64
import sys
import datetime
import time
import urllib
import jwt

username = os.environ['PSAMA_ROBOT_USER_EMAIL']
# Or simply 'sub 'PSAMA_APPLICATION|${PSAMA_APP_UUID}''
value = os.environ['PSAMA_ROBOT_USER_CLAIM']

auth0_secret = os.environ['PSAMA_CLIENT_SECRET']
signature = base64.b64decode(auth0_secret.replace("_","/").replace("-","+"))
token = jwt.encode({value: "test|" + username,'email': username},auth0_secret,algorithm='HS256')
print(token)
EOT

export AUTOMATA_USER_TOKEN=$(python /tmp/tmp_getToken.py)

export HOSTNAME="http://wildfly:8080/pic-sure-auth-microapp"

getConnectionList() {
	URL="${HOSTNAME}/psama/connection/"
	curl -k \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		$URL
}

addConnection() {
	URL="${HOSTNAME}/psama/connection"

	cat '{"uuid":"","label": "Google","id": "google-oauth2","subPrefix": "google-oauth2|","requiredFields": "[{\"label\":\"Email\", \"id\":\"email\"}]"}' > connection.json

	curl -k \
		-X POST \
		--data @connection.json \
		-H "Content-type: application/json" \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		$URL
}

getPSAMAUserMe() {
	URL="${HOSTNAME}/psama/user/me"
	curl -H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" $URL
}

getApplicationList() {
	URL="${HOSTNAME}/psama/application"
	curl -H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" ${URL}
	# Output should be something like response-psama_application.json

}

postApplication() {
	URL="${HOSTNAME}/psama/application"
	curl -X POST \
  --data '[{"uuid":"","name":"test","description":"test","url":"/testMe"}]' \
  -H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" $URL
}

checkPICSUREIRCTSearchFunction() {
	cat <<EOF > search.json
	{
	  "resourceCredentials":{
	    "BEARER_TOKEN":"${BEARER_TOKEN}",
	    "IRCT_BEARER_TOKEN":"${IRCT_APPLICATION_TOKEN}"
	  },
	  "query":"%asthma%",
	  "resourceUUID":null
	}
EOF

	curl \
		-H "Content-type: application/json" \
		--data @search.json \
		${HOSTNAME}/picsure-irct/search | jq .results[].pui -
  rm -f search.json
}

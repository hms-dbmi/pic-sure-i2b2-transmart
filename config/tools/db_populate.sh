#!/bin/sh

pip3 install PyJWT >/dev/null 2>&1

export PSAMA_CLIENT_SECRET=`grep "java:global/client_secret" /var/tmp/config/wildfly/standalone.xml | cut -d '"' -f 4`
cat <<EOT >/tmp/get_token.py
import base64
import time
import jwt
expire_time=2
signature = base64.b64decode('${PSAMA_CLIENT_SECRET}'.replace("_","/").replace("-","+"))
token = jwt.encode({
    'email': "configurator@avillach.lab",
    'sub': "configurator@avillach.lab",
    "exp": int(time.time())+(expire_time*60*60),
    "iat": int(time.time())
    },
    '${PSAMA_CLIENT_SECRET}',
    algorithm='HS256'
)
print(token.decode('utf-8'))
EOT
export AUTOMATA_USER_TOKEN=$(python /tmp/get_token.py)

# TODO: This could be done nicer!
HOSTIP=`ip -o address show eth0 | tr "  " " " | cut -d " " -f 7 | cut -d "/" -f 1 | cut -d "." -f 1,2,3`
export HOSTNAME="https://${HOSTIP}.1/psama"

addApplication() {
	URL="${HOSTNAME}/application"
	
	APP_NAME=$1
	APP_DESCRIPTION=$2
	APP_URL=$3
	
	echo '[{"uuid":"","name":"'$APP_NAME'","description":"'$APP_DESCRIPTION'","url":"'$APP_URL'"}]' > /tmp/req_application.json
	
	curl -k -X POST \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		-H "Content-type: application/json" \
		--data @/tmp/req_application.json \
		--output /tmp/resp_application.json \
		$URL
	RC=$?
	echo 'Response status: ${RC}'
	cat /tmp/resp_application.json
}

addApplication 'TRANSMART' 'i2b2/tranSmart Web Application' '/transmart'
addApplication 'PICSURE' 'PIC-SURE multiple data access API' '/picsureui'
addApplication 'IRCT' 'IRCT data access API'
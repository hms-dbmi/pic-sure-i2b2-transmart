#!/bin/sh

apk update
apk add jq curl python3 >/dev/null 2>&1
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

	curl --silent -k -X POST \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		-H "Content-type: application/json" \
		--data @/tmp/req_application.json \
		--output /tmp/resp_application.json \
		$URL
	RC=$?
	echo 'Response status: ${RC}'
	cat /tmp/resp_application.json
}

updateApplication() {
  URL="${HOSTNAME}/application"
  APP_NAME=$1
  APP_DESCRIPTION=$2
	APP_URL=$3
  APP_UUID=$(getApplicationUUIDByName $APP_NAME)
  if [ "${APP_UUID}" == "" ];
  then
    # Application name does not exist. Let's create it then
    addApplication $APP_NAME "${APP_DESCRIPTION}" "${APP_URL}"
  else
    # Application already exists. This should just be a put
    echo '[{"uuid":"'$APP_UUID'","name":"'$APP_NAME'","description":"'$APP_DESCRIPTION'","url":"'$APP_URL'"}]' > /tmp/req_application.json

    curl --silent -k -X PUT \
      -H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
      -H "Content-type: application/json" \
      --data @/tmp/req_application.json \
      --output /tmp/resp_application.json \
      $URL
    RC=$?
    echo 'Response status: ${RC}'
    cat /tmp/resp_application.json
  fi
}

getApplicationUUIDByName() {
	APP_NAME=$1
	curl --silent -k \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		-H "Content-type: application/json" \
		--output /tmp/applications.json \
		"${HOSTNAME}/application"
	jq '.[] | select(.name="'$APP_NAME'") | .uuid' /tmp/applications.json
}

getApplicationTokenByName() {
	APP_NAME=$1
	curl --silent -k \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		-H "Content-type: application/json" \
		--output /tmp/applications.json \
		"${HOSTNAME}/application"
	jq '.[] | select(.name="'$APP_NAME'") | .token' /tmp/applications.json
}

addTransmartPrivileges() {
	TM_APP_UUID=$(getApplicationUUID 'TRANSMART')
	cat <<EOT > /tmp/req_add_privileges.json
	[
		{
			"uuid": "",
			"name": "TM_ADMIN",
			"description": "Admin privilege for i2b2/tranSmart web app",
			"application": {
				"uuid": "${TM_APP_UUID}"
			}
		},
		{
			"uuid": "",
			"name": "TM_USER",
			"description": "Basic user privilege for i2b2/tranSmart web app",
			"application": {
				"uuid": "${TM_APP_UUID}"
			}
		},
		{
			"uuid": "",
			"name": "TM_STUDY_OWNER",
			"description": "Counts only privilege for i2b2/tranSmart web app",
			"application": {
				"uuid": "${TM_APP_UUID}"
			}
		},
		{
			"uuid": "",
			"name": "TM_DATASET_EXPLORER_ADMIN",
			"description": "Download privilege for i2b2/tranSmart web app",
			"application": {
				"uuid": "${TM_APP_UUID}"
			}
		}
	]
EOT
	curl --silent -k -X POST \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		-H "Content-type: application/json" \
		--data @/tmp/req_add_privileges.json \
		--output /tmp/resp_add_privileges.json \
		$URL
	RC=$?
	echo "Response status: ${RC}"
	cat /tmp/resp_application.json
}

updateApplication 'TRANSMART' 'i2b2/tranSmart Web Application' '/transmart/login/callback_processor'
updateApplication 'PICSURE' 'PIC-SURE multiple data access API' '/picsureui'
updateApplication 'IRCT' 'IRCT data access API'

export PICSURE_UUID=$(getApplicationUUIDByName 'PICSURE')
export PICSURE_TOKEN=$(getApplicationTokenByName 'PICSURE')

echo "Replacing PICSURE token in standalone.xml"
sed -i 's/<simple name="java:global/token_introspection_token" value=".*/<simple name="java:global/token_introspection_token" value="'$PICSURE_TOKEN'"/>/g' /var/tmp/config/wildfly/standalone.xml
RC=$?
echo "Response status: ${RC}"

echo "Replacing SEARCH_TOKEN in standalone.xml"
sed -i 's/<simple name="java:global/SEARCH_TOKEN" value=".*/<simple name="java:global/SEARCH_TOKEN" value="'$PICSURE_TOKEN'"/>/g' /var/tmp/config/wildfly/standalone.xml
RC=$?
echo "Response status: ${RC}"

addTransmartPrivileges

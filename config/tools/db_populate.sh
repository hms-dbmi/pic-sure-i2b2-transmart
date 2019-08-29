#!/bin/sh

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
export AUTOMATA_USER_TOKEN=$(python3 /tmp/get_token.py)
export HOSTNAME="https://127.0.0.1/psama"

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
	if [ $RC -eq 0 ];
	then
		echo "Application ${APP_NAME} has been added."
	else
		echo "Application ${APP_NAME} could not be added. Status ${RC}"
		cat /tmp/resp_application.json
	fi
}

updateApplication() {
  URL="${HOSTNAME}/application"
  APP_NAME=$1
  APP_DESCRIPTION=$2
	APP_URL=$3
  APP_UUID=$(getApplicationUUIDByName $APP_NAME)
  if [ "${APP_UUID}" == "" ];
  then
    echo "Application ${APP_NAME} does not exist. Let's create it then"
    addApplication $APP_NAME "${APP_DESCRIPTION}" "${APP_URL}"
  fi
}

getApplicationUUIDByName() {
	APP_NAME=$1
	curl --silent -k \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		-H "Content-type: application/json" \
		--output /tmp/applications.json \
		"${HOSTNAME}/application"
	# Add error handling, in case something goes wrong
	jq -r '.[] | select(.name="'$APP_NAME'") | .uuid' /tmp/applications.json
	if [ $? -ne 0 ];
	then
		echo "Could not parse the response from PSAMA!" >&2
		cat /tmp/applications.json >&2
		exit
	fi
}

getApplicationTokenByName() {
	APP_NAME=$1
	curl --silent -k \
		-H "Authorization: Bearer ${AUTOMATA_USER_TOKEN}" \
		-H "Content-type: application/json" \
		--output /tmp/applications.json \
		"${HOSTNAME}/application"
	jq -r '.[] | select(.name="'$APP_NAME'") | .token' /tmp/applications.json
	if [ $? -ne 0 ];
	then
		echo "Could not parse the response from PSAMA!" >&2
		cat /tmp/applications.json >&2
		exit
	fi
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

#addTransmartPrivileges

replacePICSUREToken() {
	PICSURE_TOKEN=$(getApplicationTokenByName 'PICSURE')
	CONFIG_FILE_PATH="/var/tmp/config/wildfly/standalone.xml"

	sed -i 's/<simple name="java:global\/token_introspection_token" value=".*" \/>/<simple name="java:global\/token_introspection_token" value="'$PICSURE_TOKEN'" \/>/' $CONFIG_FILE_PATH
	RC=$?
	echo "Replaced token_introspection_token value, with status ${RC}"
	sed -i 's/<simple name="java:global\/SEARCH_TOKEN" value=".*" \/>/<simple name="java:global\/SEARCH_TOKEN" value="'$PICSURE_TOKEN'" \/>/' $CONFIG_FILE_PATH
	RC=$?
	echo "Replaced SEARCH_TOKEN value, with status ${RC}"
}

replaceIRCTToken() {
	IRCT_TOKEN=$(getApplicationTokenByName 'IRCT')
	CONFIG_FILE_PATH="/var/tmp/config/irct/standalone.xml"
	sed -i 's/<simple name="java:global\/token_introspection_token" value=".*" \/>/<simple name="java:global\/token_introspection_token" value="'$IRCT_TOKEN'" \/>/' $CONFIG_FILE_PATH
	RC=$?
	echo "Replaced token_introspection_token (IRCT) value, with status ${RC}"
}

replaceTRANSMARTToken() {
	TRANSMART_TOKEN=$(getApplicationTokenByName 'TRANSMART')
	CONFIG_FILE_PATH="/var/tmp/config/transmart/transmartConfig/Config.groovy"
	sed -i 's/org.transmart.security.oauth.service_token = .*/org.transmart.security.oauth.service_token = "'$TRANSMART_TOKEN'"/' $CONFIG_FILE_PATH
	RC=$?
	echo "Replaced ...oauth.service_token value, with status ${RC}"
}

updateApplication 'TRANSMART' 'i2b2/tranSmart Web Application' '/transmart/login/callback_processor'
updateApplication 'PICSURE' 'PIC-SURE multiple data access API' '/picsureui'
updateApplication 'IRCT' 'IRCT data access API'
#addTransmartPrivileges

replacePICSUREToken
replaceIRCTToken
replaceTRANSMARTToken

echo "Finished reconfiguring the environment"
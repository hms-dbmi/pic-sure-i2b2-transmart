#!/bin/sh

BEARER_TOKEN="eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJnb29nbGUtb2F1dGgyfDEwNzE5NTI4NTkxNTQyMjY0MzI4MCIsInVzZXJfaWQiOiJnb29nbGUtb2F1dGgyfDEwNzE5NTI4NTkxNTQyMjY0MzI4MCIsIm5hbWUiOiJHYWJvciBLb3JvZGkiLCJleHAiOjE1NjM5Nzc4ODUsImlhdCI6MTU2Mzg5MTQ4NSwiZW1haWwiOiJna29yb2RpQGdtYWlsLmNvbSJ9.N8zetCURveNikw3EU7XkYG3P0g5SmewTA3KX6azQSSI"
IRCT_APPLICATION_TOKEN="eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJnb29nbGUtb2F1dGgyfDEwNzE5NTI4NTkxNTQyMjY0MzI4MCIsInVzZXJfaWQiOiJnb29nbGUtb2F1dGgyfDEwNzE5NTI4NTkxNTQyMjY0MzI4MCIsIm5hbWUiOiJHYWJvciBLb3JvZGkiLCJleHAiOjE1NjM5Nzc4ODUsImlhdCI6MTU2Mzg5MTQ4NSwiZW1haWwiOiJna29yb2RpQGdtYWlsLmNvbSJ9.N8zetCURveNikw3EU7XkYG3P0g5SmewTA3KX6azQSSI"

CONFIG_DIR=/usr/local/docker-config

loggerInfo () {
	MSG=$*
	TIMESTAMP=$(date +%Y-%b-%d_%H-%M-%S)
	echo "${TIMESTAMP} [INFO ] ${MSG}"
}

loggerError() {
	MSG=$*
	TIMESTAMP=$(date +%Y-%b-%d_%H-%M-%S)
	echo "${TIMESTAMP} [ERROR] ${MSG}"
}

checkExitStatus() {
	STATUS=$1; shift
	PRE_ERR_MSG=$1; shift
	PRE_SUC_MSG=$1; shift
	
	MSG=$*
	if [ $STATUS -ne 0 ];
	then
		loggerError "${PRE_ERR_MSG} ${MSG}"
		exit
	else
		loggerInfo "${PRE_SUC_MSG} ${MSG}"
	fi
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

	curl -k --silent \
		-H "Content-type: application/json" \
		--data @search.json \
		https://localhost/picsure-irct/search | jq .results[].pui -
	#  | wc | tr "  " " " 

	#rm -f search.json
}

# ******************* Main Process *******************
loggerInfo "Starting verification"
# Verify application performance

#checkPICSUREIRCTSearchFunction

# Check if settings exist, configured and correct


grep '<connection-url>jdbc:mysql://' $CONFIG_DIR/wildfly/standalone.xml >/dev/null
RC=$?

grep '<simple name="java:global/verify_user_method" value="tokenIntrospection"/>' $CONFIG_DIR/wildfly/standalone.xml >/dev/null
RC=$?
checkExitStatus $RC 'Failed to' 'Successfuly found' 'the correct settings for *verify_user_method* variable in *wildfly* standalone.xml file'

grep '<simple name="java:global/token_introspection_url" value="http://wildfly:8080/pic-sure-auth-services/auth/token/inspect"/>' $CONFIG_DIR/wildfly/standalone.xml >/dev/null
RC=$?
checkExitStatus $RC 'Failed to' 'Successfully found' 'the correct settings for *token_introspection_url* variable in *wildfly* standalone.xml file'

loggerInfo "Finished verification"
#!/bin/sh

export SUPERUSER_EMAIL_PARAM=$1

apt-get update -y >/dev/null
apt-get install -y apt-utils curl >/dev/null
clear

export HMSDBMI_GITHUB_URL='https://raw.githubusercontent.com/hms-dbmi'
export CONNECTION_TIMEOUT_SECONDS=10

export PICSURE_DB_NAME="picsure"
export PSAMA_DB_NAME="auth"
export IRCT_DB_NAME="irct"

createPSAMADB() {
	cp $HOME/dbconfig/login_config.psama $HOME/.my.cnf
	# Create PSAMA database schema. This script will delete all data and all table
	# definitions, and will re-create the empty tables with the latest and greates
	# from the GitHub repo
	curl --silent --output createdb_psama.sql \
		$HMSDBMI_GITHUB_URL/pic-sure-auth-microapp/master/pic-sure-auth-db/db/create_db_auth.sql
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS < createdb_psama.sql
	RC=$?
	rm -f createdb_psama.sql
}

addConnection() {
	CONN_LABEL=$1
	CONN_ID=$2
	CONN_SUB=$3
	cat <<EOT >populate_auth_db.sql

SET @uuidConnection = REPLACE(uuid(),'-','');
INSERT INTO connection VALUES (
  unhex(@uuidConnection),
  '${CONN_LABEL}',
  '${CONN_ID}',
  '${CONN_SUB}',
  '[{\"label\":\"Email\", \"id\":\"email\"}]'
	);

SET @uuidMetaDataForConnection = REPLACE(uuid(),'-','');
INSERT INTO userMetadataMapping (uuid, auth0MetadataJsonPath, connectionId, generalMetadataJsonPath)
		VALUES
			(unhex(@uuidMetaDataForConnection), '$.email', unhex(@uuidConnection), '$.email');
EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < populate_auth_db.sql
	rm -f populate_auth_db.sql
}

addSuperUser() {

	USER_EMAIL=$1
	USER_CONN=$2

	# If no connection is given, use 'Google' as the default one.
	if [ ! -n "$USER_CONN" ]
	then
		USER_CONN='Google'
	fi

	cat <<EOT > db_psama_createSuperUser.sql
	START TRANSACTION;

	# Create user record with random UUID
	SET @uuidUser = REPLACE(uuid(),'-','');

	INSERT INTO user (
		uuid,
		general_metadata,
		connectionId,
		email,
		matched
	) VALUES (
		unhex(@uuidUser),
		"{\"email\":\"${USER_EMAIL}\"}",
		(SELECT uuid FROM connection WHERE label = '${USER_CONN}'),
		'${USER_EMAIL}',
		false
	);

	# Add the initial ADMIN role for the user.
	# Assuming, that all superuser privileges have been
	# assigned to this role, already, during creation
	# of the database.
	INSERT INTO user_role (
		user_id,
		role_id
	) VALUES (
		unhex(@uuidUser),
		(SELECT MIN(uuid) FROM management_view WHERE role_name LIKE 'PIC-SURE Top Admin')
	);

	COMMIT;
EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < db_psama_createSuperUser.sql
	rm -f db_psama_createSuperUser.sql
}

# This will add just a user record, and NOT add any predefined roles to
# the user_role table. You will need to specifically add the role later
# with the assignRoleToUser() sub call.
addNormalUser() {
	USER_EMAIL=$1
	cat <<EOT > db_psama_createNormalUser.sql
	START TRANSACTION;

	# Create user record with random UUID
	SET @uuidUser = REPLACE(uuid(),'-','');

	INSERT INTO user (
		uuid,
		general_metadata,
		email,
		subject,
		matched
	) VALUES (
		unhex(@uuidUser),
		"{\"email\":\"${USER_EMAIL}\"}",
		'${USER_EMAIL}',
		'${USER_EMAIL}',
		false
	);
	COMMIT;
EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < db_psama_createNormalUser.sql
	rm -f db_psama_createNormalUser.sql
}

addApplication() {
	APP_NAME=$1
	APP_DESCRIPTION=$2
	APP_URL=$3

	cat <<EOT >addApplication.sql
	SET @uuidApplication = REPLACE(uuid(),'-','');
	INSERT INTO application (uuid, description, enable, name, token, url)
	VALUES
		(
		unhex(@uuidApplication),
		'${APP_DESCRIPTION}',
		1,
		'${APP_NAME}',
		NULL,
		'${APP_URL}'
	);
EOT

	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < addApplication.sql
	rm -f addApplication.sql

}

createPICSUREDB() {
	cp $HOME/dbconfig/login_config.picsure $HOME/.my.cnf

	# definitions, and will re-create the empty tables with the latest and greates
	# from the GitHub repo
	curl --silent --output create_picsure_db.sql \
		${HMSDBMI_GITHUB_URL}/pic-sure/master/pic-sure-api-data/src/main/resources/db/create_db_picsure.sql
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS < create_picsure_db.sql
	rm -f create_picsure_db.sql
}

addPICSUREResource() {
	RS_NAME=$1
	RS_DESCRIPTION=$2
	RS_URL_PATH=$3

	cat <<EOT >addPICSUREResource.sql
SET @uuidResource = REPLACE(uuid(),'-','');
INSERT INTO resource (uuid, targetURL, resourceRSPath, description, name, token)
VALUES
	(
	unhex(@uuidResource),
	NULL,
	'${RS_URL_PATH}',
	'${RS_DESCRIPTION}',
	'${RS_NAME}',
	NULL
);
EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PICSURE_DB_NAME} < addPICSUREResource.sql
	rm -f addPICSUREResource.sql
}

createIRCTDB() {
	cp $HOME/dbconfig/login_config.irct $HOME/.my.cnf
	# Create IRCT database schema. This script will delete all data and all table
	# definitions, and will re-create the empty tables with the latest and greates
	# from the GitHub repo
	curl --silent --output create_irct_db.sql \
		$HMSDBMI_GITHUB_URL/IRCT/master/IRCT-API/src/main/resources/sql_templates/create_irct_db.sql
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS < create_irct_db.sql
	rm -f create_irct_db.sql
}

initDefaultIRCTResource() {
	RESOURCE_NAME=$1
	RESOURCE_USERNAME=$2
	RESOURCE_PASSWORD=$3
	RESOURCE_TYPE=$4
	cat <<EOT >addIRCTResource.sql

	SET @idResource = (SELECT id FROM Resource WHERE name = '${RESOURCE_NAME}');

	DELETE FROM Resource_relationships WHERE Resource_id = @idResource;
	DELETE FROM Resource_PredicateType WHERE Resource_id = @idResource;
	DELETE FROM Resource_LogicalOperator WHERE id = @idResource;
	DELETE FROM Resource_dataTypes WHERE Resource_id = @idResource;
	DELETE FROM resource_parameters WHERE id = @idResource;
	DELETE FROM Resource WHERE id = @idResource;;

	INSERT INTO Resource (id, implementingInterface, name, ontologyType)
	VALUES
		(@idResource, '${RESOURCE_TYPE}', '${RESOURCE_NAME}', 'TREE');

	INSERT INTO resource_parameters (id, value, name)
	VALUES
		(@idResource, NULL, 'clientId'),
		(@idResource, 'i2b2demo', 'domain'),
		(@idResource, 'true', 'ignoreCertificate'),
		(@idResource, NULL, 'namespace'),
		(@idResource, '${RESOURCE_PASSWORD}', 'password'),
		(@idResource, '${RESOURCE_NAME}', 'resourceName'),
		(@idResource, '${RESOURCE_URL}', 'resourceURL'),
		(@idResource, NULL, 'transmartURL'),
		(@idResource, '${RESOURCE_USERNAME}', 'username');

	INSERT INTO Resource_dataTypes (Resource_id, dataTypes)
	VALUES
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:DATETIME'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:DATE'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:INTEGER'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:STRING'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:FLOAT');

	INSERT INTO Resource_LogicalOperator (id, logicalOperator)
	VALUES
		(@idResource, 'AND'),
		(@idResource, 'OR'),
		(@idResource, 'NOT');

	INSERT INTO Resource_PredicateType (Resource_id, supportedPredicates_id)
	VALUES
		(@idResource, (SELECT id FROM PredicateType WHERE name = 'CONTAINS')),
		(@idResource, (SELECT id FROM PredicateType WHERE name = 'CONSTRAIN_MODIFIER')),
		(@idResource, (SELECT id FROM PredicateType WHERE name = 'CONSTRAIN_VALUE')),
		(@idResource, (SELECT id FROM PredicateType WHERE name = 'CONSTRAIN_DATE'));

	INSERT INTO Resource_relationships (Resource_id, relationships)
	VALUES
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:PARENT'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:CHILD'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:SIBLING'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:MODIFIER'),
		(@idResource, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:TERM');

EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${IRCT_DB_NAME} < addIRCTResource.sql
	rm -f addIRCTResource.sql
}

addPrivilege() {
	PRIV_NAME=$1
	PRIV_DESCRIPTION=$2
	cat <<EOT > db_psama_createPrivilege.sql
	SET @uuidPrivilege = REPLACE(uuid(),'-','');
	INSERT INTO privilege (uuid, description, name, application_id)
	VALUES
		(
		unhex(@uuidPrivilege),
		'${PRIV_DESCRIPTION}',
		'${PRIV_NAME}',
		NULL
		);
EOT
  mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < db_psama_createPrivilege.sql
  rm -f db_psama_createPrivilege.sql
}

addRole() {
	ROLE_NAME=$1
	ROLE_DESCRIPTION=$2

	cat <<EOT > db_psama_createRole.sql
	SET @uuidRole = REPLACE(uuid(),'-','');
	INSERT INTO role (uuid, name, description)
	VALUES
		(
		unhex(@uuidRole),
		'${ROLE_NAME}',
		'${ROLE_DESCRIPTION}'
		);
EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < db_psama_createRole.sql
	rm -f db_psama_createRole.sql
}

assignPrivilegeToRole() {
	PRIVILEGE_NAME=$1
	ROLE_NAME=$2

	cat <<EOT > db_psama_assignPrivilege.sql
	INSERT INTO role_privilege (role_id, privilege_id)
	VALUES
	(
		(SELECT uuid FROM role WHERE name = '${ROLE_NAME}'),
		(SELECT uuid FROM privilege WHERE name = '${PRIVILEGE_NAME}')
	);
EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < db_psama_assignPrivilege.sql
	rm -f db_psama_assignPrivilege.sql

}

assignRoleToUser() {
	USER_EMAIL=$1
	ROLE_NAME=$2

	cat <<EOT > db_psama_assignRoleToUser.sql
	INSERT INTO user_role (user_id, role_id)
VALUES
	(
		(SELECT uuid FROM user WHERE email = '${USER_EMAIL}'),
		(SELECT uuid FROM role WHERE name = '${ROLE_NAME}')
	);
EOT
	mysql --connect-timeout=$CONNECTION_TIMEOUT_SECONDS ${PSAMA_DB_NAME} < db_psama_assignRoleToUser.sql
	rm -f db_psama_assignRoleToUser.sql
}

# Initialize the basic PSAMA database.
createPSAMADB

addPrivilege 'ADMIN' 'PIC-SURE Auth admin for managing users.'
addPrivilege 'SUPER_ADMIN' 'PIC-SURE Auth super admin for managing roles/privileges/application/connections'

addConnection 'Google' 'google-oauth2' 'google-oauth2|'

addRole 'PIC-SURE Top Admin' 'PIC-SURE Auth Micro App Top admin including Admin and super Admin'
assignPrivilegeToRole 'SUPER_ADMIN' 'PIC-SURE Top Admin'
assignPrivilegeToRole 'ADMIN' 'PIC-SURE Top Admin'

# TODO: Fix the way arguments are passed in 
# (maybe --env on the docker run line?!)
# Loop through the email addresses, passed into this script
#echo "Processing email address list: ${SUPERUSER_EMAIL_PARAM}"
#count=`echo $SUPERUSER_EMAIL_PARAM | awk -F, {'print NF'}`
#i=1
#while [ $i -le $count ]
#do
# superuser_email=`echo $strn | cut -d, -f${i}`
# addSuperUser $superuser_email 'Google'
# i=`expr $i + 1`
#done

addSuperUser 'andrew.guidetti@gmail.com' 'Google'
addSuperUser 'gkorodi@gmail.com' 'Google'

# Adding a normal user, with no roles, and assigning the TopAdmin role
# to it, is the same as calling addSuperUser, but the connection will
# not be set for this user.
addNormalUser 'configurator@avillach.lab'
assignRoleToUser 'configurator@avillach.lab' 'PIC-SURE Top Admin'

# Initialize the IRCT database, with a single default user. It is already
# there in the create script, but this will overwrite it. Allows for more
# flexibility, and shows the example of how to add an IRCT resource. However
# other type of resources should NOT be added this way!
createIRCTDB
initDefaultIRCTResource 'i2b2-wildfly-default' 'demo' 'demouser' \
	'http://i2b2-wildfly:9090/i2b2/services/' \
	'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2XMLOnlyCountRI'

# Initialize the PICSURE database, with a single simple IRCT resource.
createPICSUREDB
addPICSUREResource 'IRCT' 'IRCT Resource' 'http://wildfly:8080/pic-sure-irct-resource/pic-sure/v1.4'

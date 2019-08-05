#!/bin/sh

cd /tmp

psamaConfiguration() {
	# These are generic privileges, PSAMA is
	# NOT a valid application, but rather a
	# special word. No application_id will be
	# associated with these privileges
	addPrivilege PSAMA ADMIN
	addPrivilege PSAMA SUPER_ADMIN

	addRole "PIC-SURE Top Admin"
	assignPrivilegeToRole "ADMIN,SUPER_ADMIN" "PIC-SURE Top Admin"

	# Create a new application, and assign
	# privileges to it
	addApplication TRANSMART
	addPrivilege TM_PUBLIC_USER
	assignPrivilegeToApp TM_PUBLIC_USER TRANSMART
	addPrivilege TM_STUDY_OWNER
	assignPrivilegeToApp TM_STUDY_OWNER TRANSMART
	addPrivilege TM_DATASET_EXPLORER_ADMIN
	assignPrivilegeToApp TM_DATASET_EXPLORER_ADMIN TRANSMART
	addPrivilege TM_ADMIN
	assignPrivilegeToApp TM_ADMIN TRANSMART

	addRole TM_LEVEL1
	assignPrivilegeToRole "TM_PUBLIC_USER,TM_STUDY_OWNER" "TM_LEVEL1"
	addRole TM_LEVEL2
	assignPrivilegeToRole "TM_PUBLIC_USER,TM_DATASET_EXPLORER_ADMIN" "TM_LEVEL2"
	addRole TM_ADMIN
	assignPrivilegeToRole "TM_PUBLIC_USER,TM_ADMIN" "TM_ADMIN"


	# Create additional applications. These will
	# not have any privileges assigned to them.
	addApplication IRCT
	addApplication PICSURE
	addApplication HPDS

}

mustExistConnection() {
	CONNECTION_NAME=$1
	echo "[ERROR] Connection ${CONNECTION_NAME} does not exist. It is mandatory. Exiting"
	exit 1
}

mayExistConnection() {
	CONNECTION_NAME=$1
	return "maybe"
}

addConnection() {
	retval=1
	return "$retval"
}

mustExistRole() {
	ROLE_NAME=$1
	echo "[ERROR] Role ${ROLE_NAME} does not exist. It is mandatory. Exiting"
	exit 1
}

createAdminUser() {
	USER_NAME=$1
	USER_EMAIL=$2
	USER_ROLE=$3

	retval=1
	# TODO: Implement SQL Insert script
	return "$retval"
}

mustExistConnection Google

if [ $(mayExistConnection HMS) == "true" ];
then
	echo 'Connection HMS already exists'
else
	echo 'Connection HMS does NOT exist.'
fi

addConnection HMS
retval=$?
if [ "$retval" == 0 ];
then
	echo 'Added new connection HMS'
else
	echo 'Could not add connection HMS'
fi

mustExistRole 'PIC-SURE Top Admin'

# Create and TOP_ADMIN user
curl \
	--output addAdmin.sql \
	https://raw.githubusercontent.com/hms-dbmi/pic-sure-auth-microapp/master/pic-sure-auth-db/db/insert_user_ADMINGMAIL.sql
sed -i 's/__SUPERUSER_GMAIL_ADDRESS__/gkorodi@gmail.com/g' addAdmin.sql


mysql auth < addAdmin.sql

createAdminUser "Paul Avillach" "pavillach@gmail.com" 'PIC-SURE Top Admin'

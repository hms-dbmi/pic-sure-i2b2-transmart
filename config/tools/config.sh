#!/usr/bin/env bash

# Run it like:
# `CONFIG_DIR=/usr/local/docker-config config/tools/config.sh /tmp/secrets.txt`
# First arg is the full path of the secrets.txt file
SECRETS_FILE=$1

if [ "${SECRETS_FILE}" == "" ];
then
  printf "\nERROR: The first argument, name of the secrets file, is mandatory.\n\n"
  exit 2
fi

if [ "${CONFIG_DIR}" == "" ];
then
	printf "\nERROR: CONFIG_DIR environment variable is not set, or empty. Cannot proceed.\n\n"
	exit 2
fi

SED_VERSION=$(sed --version 2>/dev/null | head -1 | cut -d ")" -f 2 | tr -d " ")

LOGFILE=logfile_`date +%Y%m%d_%H%M%S`.log
touch ${LOGFILE}

echo "Running ...."

echo "Replace template directory"
rm -fR ${CONFIG_DIR}/*
cp -r config/template/* ${CONFIG_DIR}
echo "Done"

echo "Start replacement"
for FN in `find ${CONFIG_DIR} -name "*.*"`
do
  FILE_TO_ACT_ON="${FN}"
  echo "**************** Processing file ${FILE_TO_ACT_ON} ****************" >> ${LOGFILE}
  for KEY_VALUE_PAIR in $(cat ${SECRETS_FILE})
  do
    if [ "${KEY_VALUE_PAIR}" != "" ] && [ $(echo "${KEY_VALUE_PAIR}" | cut -c 1) != "#" ];
    then
        echo "Replacing kv pair '${KEY_VALUE_PAIR}'" >> ${LOGFILE}

        KEY=$(echo "${KEY_VALUE_PAIR}" | cut -d "=" -f 1)
        VALUE=$(echo "${KEY_VALUE_PAIR}" | cut -d "=" -f 2)

        VALUE=${VALUE//'/'/'\/'}
        if [ "${SED_VERSION}" == "" ];
        then
          # Stupid macOSX 'feature'
        	sed -i '' "s/__${KEY}__/${VALUE}/g" ${FILE_TO_ACT_ON} 2>> ${LOGFILE}
        else
        	sed -i "s/__${KEY}__/${VALUE}/g" ${FILE_TO_ACT_ON} 2>> ${LOGFILE}
        fi
        if [ $? -ne 0 ];
        then
            echo "Failed :(" >> ${LOGFILE}
        fi
    else
        echo "Skipping empty or comment line '${KEY_VALUE_PAIR}' in secrets.txt" >> ${LOGFILE}
    fi
  done
done

echo "Finished. Log file generated ${LOGFILE}"
echo ""

find ${CONFIG_DIR} -exec grep -H "__" {} \; 2>/dev/null

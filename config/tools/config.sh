#!/usr/bin/env bash

# First arg is the full path of the secrets.txt file
SECRETS_FILE=$1

if [ "${SECRETS_FILE}" == "" ];
then
  printf "\nERROR: The first argument, name of the secrets file, is mandatory.\n\n"
  exit 2
fi

LOGFILE=logfile_`date +%Y%m%d_%H%M%S`.log
touch ${LOGFILE}
echo "Running ...."

echo "Replace template directory"
rm -fR /usr/local/docker-config/*
cp -r config/template/* /usr/local/docker-config
#find /usr/local/docker-config -name "*.*"
echo "Done"

echo "Start replacement"
for FILE_TO_ACT_ON in `find /usr/local/docker-config -name "*.*"`
do
  echo "**************** Processing file ${FILE_TO_ACT_ON} ****************" >> ${LOGFILE}
  for KEY_VALUE_PAIR in $(cat ${SECRETS_FILE})
  do
    if [ "${KEY_VALUE_PAIR}" != "" ] && [ $(echo "${KEY_VALUE_PAIR}" | cut -c 1) != "#" ];
    then
        echo "Replacing kv pair '${KEY_VALUE_PAIR}'" >> ${LOGFILE}
        KEY=$(echo "${KEY_VALUE_PAIR}" | cut -d "=" -f 1)
        VALUE=$(echo "${KEY_VALUE_PAIR}" | cut -d "=" -f 2)
        echo "The variable '${KEY}' will be replaced by value '${VALUE}'" >> ${LOGFILE}

        VALUE=${VALUE//'/'/'\/'}
        sed -i '' "s/__${KEY}__/${VALUE}/g" ${FILE_TO_ACT_ON} 2>> ${LOGFILE}

        if [ $? -ne 0 ];
        then
            echo "Failed :(" >> ${LOGFILE}
        else
            echo "Done :)" >> ${LOGFILE}
        fi
    else
        echo "Skipping empty or comment line '${KEY_VALUE_PAIR}' in secrets.txt" >> ${LOGFILE}
    fi
  done
done
echo "Finished. Log file generated ${LOGFILE}"
echo ""

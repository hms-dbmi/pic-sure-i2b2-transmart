# pic-sure-i2b2-transmart
Research infrastructure powered by PIC-SURE and i2b2/tranSMART. This serves as a reference implementation 
for use in production environments where the databases reside off the application server.

All containers are based on public images. To configure the environment, follow the instructions provided in the [config/](config/) directory.

# PreRequisites

Ensure that you have `docker-compose` installed on the host machine.

# Installation

On a new server, or docker machine, run the following commands to install and start up the whole stack. 

It requires privileges to the GitHub repo and to be able run `docker` commands on the machine itself.

```

cd /var/tmp
rm -fR pic-sure-i2b2-transmart
git clone https://github.com/hms-dbmi/pic-sure-i2b2-transmart.git
cd pic-sure-i2b2-transmart/

docker-compose down
docker-compose pull
docker-compose build

```

# Create `config` files

The repo comes with sample configuration files, that are required for the correct operation. They are collected in the `./config` subdirectory of the repo. If you are configuring the stack without docker, you can place these files yourself in the appropriate location.

For docker based installation, copy the entire directory out of the repo to, for example, the `/usr/local/docker-config` directory.

```
cd /var/tmp/pic-sure-i2b2-transmart/
cp -r config /usr/local/docker-config

```

After distributing the above template files, please follow the instructions in the [config/README.md](config/README.md) file, to replace the values for each variable documented.

A good initial test is to bring up the `httpd` service, and see if we can access the provided URLs.

If the IP address of the node is **192.168.99.100**, for example, we can see if the `httpd` service can be reached via [http://192.168.99.100/](http://192.168.99.100/)

# Configure `PSAMA`

The `psama` service and the `psamaui` component of the `httpd` service works together to allow administration of users, applications and roles for the users to those applications. The `psama` service relies on its own mysql connection to a database, that has to be called `auth`.

When starting up `psama` for the first time, the initial database has no users in it. The initial superuser has to be manually added to the `auth` database.

Take a look at the script in the [first_time_run_the_system_and_insert_admin_user.sql](https://raw.githubusercontent.com/hms-dbmi/pic-sure-auth-microapp/master/pic-sure-auth-db/db/tools/first_time_run_the_system_and_insert_admin_user.sql) script. Change the e-mail address (has to be a gmail.com e-mail address) and run the script on the database. All other administration of the users/roles/privileges can be done via the `psamaui` webinterface.

# Configure other back-end services

**IRCT** and **PIC-SURE** services might require additional configuration. 

```
export STACK_NAME=pic-sure-i2b2-transmart
export CONFIG_DIR=/usr/local/docker-config


```



# Configure `i2b2/tranSmart`

Update the `Config.groovy` file with the application token obtained from the `psama` service and restart the `transmart` service.

```
STACK_NAME=pic-sure-i2b2-transmart CONFIG_DIR=/usr/local/docker-config \
	docker-compose --file /var/tmp/pic-sure-i2b2-transmart/docker-compose.yml restart transmart


```

or

```
docker-compose --file /var/tmp/pic-sure-i2b2-transmart/docker-compose.yml restart transmart


```



## Putting it all together

```
#!/bin/bash

# Set the configuration variabales
export STACK_NAME=pic-sure-i2b2-transmart
export CONFIG_DIR=/usr/local/docker-config

# Build the images locally for the whole stack
cd /var/tmp
rm -fR pic-sure-i2b2-transmart
git clone https://github.com/hms-dbmi/pic-sure-i2b2-transmart.git
cd pic-sure-i2b2-transmart/

docker-compose down
docker-compose pull
docker-compose build

# Copy the config templates to the configuration directory
cd /var/tmp/pic-sure-i2b2-transmart/
cp -r config ${CONFIG_DIR}

# Update the placeholder values
# ***************************
#
# This is a manual process!!!
#
# ***************************

# Create a superuser account in `psama` for administration
# ***************************
#
# Use the first_time_run_the_system_and_insert_admin_user.sql script
# on the MySQL database to add a personal account that can start 
# managing the roles and privileges.
#
# ***************************


# Start up `psama` service
docker-compose --file /var/tmp/pic-sure-i2b2-transmart/docker-compose.yml up -d psama
docker-compose --file /var/tmp/pic-sure-i2b2-transmart/docker-compose.yml logs -f psama


# Create application 
# ***************************
#
# Log into the `psama ui` and follow the administration 
# instructions for creating applications, roles and privileges.
#
# ***************************


# Start all other services
docker-compose --file /var/tmp/pic-sure-i2b2-transmart/docker-compose.yml up -d
docker-compose --file /var/tmp/pic-sure-i2b2-transmart/docker-compose.yml logs -f 

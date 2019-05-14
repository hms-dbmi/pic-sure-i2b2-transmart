# Configuration of the PIC-SURE-I2B2-TRANSMART Stack

In this folder, you can find the configuration files, required by each service running in this implementation.

This document should provide enough contextual information for you to
deploy this stack, if you are not using docker you can still
use this as a reference. The files modified here are the same for the
services being hosted no matter how you host them.

The layout of this folder's contents is important as each path is mapped
as a volume into the running environment, when using docker. Your first step
in deploying this stack is to copy these contents to /usr/local/docker-config/ on
your docker host and modify them according to your infrastructure and requirements.

If you are not using the provided docker-compose.yml, and not using docker at all,
you can still use the mapped path in the docker-compose.yml file on the server directly.

<pre>
.
├── README.md
├── fractalis
│   └── config.py
├── httpd
│   ├── cert
│   │   ├── server.chain
│   │   ├── server.key
│   │   └── server.crt
│   │
│   └── htdocs
│       ├── picsureui
│       │   └── settings
│       │       └── settings.json
│       └── psamaui
│           └── settings
│               └── settings.json
├── irct
│   └── wildfly
│       └── standalone
│           └── configuration
│               └── standalone.xml
├── i2b2-wildfly
│   └── wildfly
│       └── standalone
│           └── configuration
│               └── standalone.xml
├── wildfly
│   └── standalone.xml
│   └── deployments/
│
└── transmart
    └── transmartConfig
        ├── Config.groovy
        └── DataSource.groovy

</pre>

# Conventions used throughout these files

Each file containes one or more configuration variables that require
values to be filled in for the corresponding service to operate.

This document lists all variables that need to have an actual value.

All values that need to be replaced are noted as "__VARIABLE_VALUE__". Depending on the variable, it either requires a string value, within quotes, a numeric value, or a boolean value (true or false). The descriptions below for each variable will indicate the type and if possible, suggestions for a value.

## Database Configuration

https://github.com/hms-dbmi/PIC-SURE-resources/tree/master/resource/i2b2

## Database Initialization

### i2b2 DB

The configuration and ETL process is not in the scope of this document.

Once the i2b2 database has been configured and started, the IP Address, port, database name and the username/password for all user accounts needs to be collected, and preferrably entered into the `secrets.txt` file. <small>(See below for configuration management, and variables used during.)</small>

### Authorization DB

To start with the stack, the `auth` database needs to be initialized with the first admin user's information.

If the database is not yet created, use the script [https://raw.githubusercontent.com/hms-dbmi/pic-sure-auth-microapp/master/pic-sure-auth-db/db/create_db_auth.sql](https://raw.githubusercontent.com/hms-dbmi/pic-sure-auth-microapp/master/pic-sure-auth-db/db/create_db_auth.sql) to create an empty database.

Follow the instructions on the [README.md](https://github.com/hms-dbmi/pic-sure-auth-microapp) of the `pic-sure-auth-microapp` project. Under the heading "*To add an initial top admin user in the system*". Or just execute the mentioned script from [here](https://raw.githubusercontent.com/hms-dbmi/pic-sure-auth-microapp/master/pic-sure-auth-db/db/tools/first_time_run_the_system_and_insert_admin_user.sql), but first update it with your own Google authenticated account.

The script will set up a default `connection` for Google authenticated users, and that is the reason the initial account has to be an account authenticated by Google.

### PIC-SURE DB

To be able to execute an initial search from the `picsureui` component, the stack configuration assumes, that at least one PIC-SURE resource has been set up in the `picsure` MySQL database.

The database setup script is stored here: [https://raw.githubusercontent.com/hms-dbmi/pic-sure/master/pic-sure-api-data/src/main/resources/db/create_db_picsure.sql](https://raw.githubusercontent.com/hms-dbmi/pic-sure/master/pic-sure-api-data/src/main/resources/db/create_db_picsure.sql) and the script to create the initial resource is stored here: [https://raw.githubusercontent.com/hms-dbmi/pic-sure/master/pic-sure-api-data/src/main/resources/db/insert_resource_irct-nhanes.sql](https://raw.githubusercontent.com/hms-dbmi/pic-sure/master/pic-sure-api-data/src/main/resources/db/insert_resource_irct-nhanes.sql)

After creating a *resource* entry in the database, please note the generated UUID, and add it to the `secrets.txt` file, where configuration values are stored. This UUID will be used in the `config/templates/httpd/html/picsureui/settings/settings.json` file.

### IRCT DB

To query resources via the `IRCT` service, and to be able to configure an `IRCT` type resource in PIC-SURE, the stack requires an `IRCT` database to be configured. 

To create the database, and an initial NHANES resource in it, use the script [https://github.com/hms-dbmi/IRCT/blob/master/IRCT-API/src/main/resources/sql_templates/create_irct_db.sql](https://github.com/hms-dbmi/IRCT/blob/master/IRCT-API/src/main/resources/sql_templates/create_irct_db.sql)



### *irct* service

If the `IRCT` service is required, the configuration of its _standalone.xml_ file can be found in the _templates/irct/wildfly/standalone/configure/standalone.xml_ path of this repo.



  *Variable List*

  Name | Description/Sample
  -----|-------------
    `IRCT_DB_HOST` |  <br /><br /><small>127.0.0.1</small>
    `IRCT_DB_NAME` | The name of the MySQL database, where IRCT data is stored. <br /><br /><small>irct</small>
    `IRCT_DB_PASSWORD` | The MySQL database password for the corresponding IRCT_DB_USER username. <br /><br /><small>password</small>
    `IRCT_DB_PORT` | The port number where the MySQL database engine is listening on <br /><br /><small>3306</small>
    `IRCT_DB_USERNAME` | The MySQL database username, to access the IRCT data. <br /><br /><small>irctdbuser</small>
    `IRCT_RESULTS_DATA_FOLDER` |  <br /><br /><small>/tmp</small>
    `IRCT_TOKENINTROSPECTION_TOKEN` |  <br /><br /><small>test</small>
  
### *psama* service



  *Variable List*

  Name | Description/Sample
  -----|-------------
    `PSAMA_DB_HOST` |  <br /><br /><small>127.0.0.1</small>
    `PSAMA_DB_PORT` |  <br /><br /><small>3306</small>
    `PSAMA_DB_NAME` |  <br /><br /><small>auth</small>
    `PSAMA_DB_USERNAME` |  <br /><br /><small>&lt;USERNAME&gt;</small>
    `PSAMA_DB_PASSWORD` |  <br /><br /><small>&lt;STRONG_PASSWORD&gt;</small>
    `PSAMA_CLIENT_SECRET` |  <br /><br /><small>$$$$$$</small>
    `PSAMA_CLIENT_ID` | A unique string, either provided by the authentication service provider, or generated by some other means. <br /><br /><small>&lt;RANDOM_STRING&gt;</small>
    `PSAMA_SYSTEM_NAME` | The name of the stack, that will be used in the e-mail messages, that are sent to the user. <br /><br /><small>psama-service</small>
    `PSAMA_CLIENT_SECRET_IS_BASE_64` | Is the client secret for PSAMA is base64 encoded? <br /><br /><small>false</small>
    `PSAMA_USER_ACTIVATION_TEMPLATE_PATH` | The full path of a (possibly templated) file in the container, that is used as a blueprint for the content of the e-mail being sent when a new user is activated. <br /><br /><small>$WILDFLY_HOME/standalone/configuration/activation.mustache</small>
    `PSAMA_USER_ACTIVATION_REPLY_TO` | E-mail address to reply to when receiving activation e-mail <br /><br /><small>username@emailservercom</small>
    `PSAMA_TOS_ENABLED` | True/False value for indicating if the TermsOfService feature is enabled. <br /><br /><small>false</small>
    `PSAMA_GMAIL_FROM_EMAIL` |  <br /><br /><small>hms.dbmi.data.infrastructure@gmail.com</small>
    `PSAMA_GMAIL_USERNAME` |  <br /><br /><small>username@emailserver.com</small>
    `PSAMA_GMAIL_PASSWORD` | The MySQL password, corresponding to the PSAMA_DB_USER username, to access the database. <br /><br /><small>&lt;STRONG_PASSWORD&gt;</small>
    `PSAMA_AUTH_DOMAIN` | A URL that points to the domain, generated by the Auth0 service provider. <br /><br /><small>https://&lt;accountname&gt;.auth0.com/</small>
    `PSAMA_AUTH0_HOST` | The URL where auth0 application is hosted <br /><br /><small>http://&lt;accountname&gt;.auth0.com</small>
  
### *pic-sure* service



### *i2b2/tranSmart* service

i2b2/tranSmart is a Java application, running on a Tomcat application server. Files configured are *Config.groovy* and *DataSource.groovy*.



### *i2b2-wildfly* service



### *fractalis* service

Fractalis is a python based back-end service for the fractalis i2b2/tranSmart plugin. In conjunction with `worker`, `redis` and `rabbitmq` services, it interacts with datasources, to produce a rich data exploration environment.

The *docker-compose.yml* file sets up the path inside the container for the *config.py* file, where configuration variables are stored.


  *Variable List*

  Name | Description/Sample
  -----|-------------
    `FRACTALIS_CLIENT_SECRET` | The client secret, shared with the PSAMA application. <br /><br /><small></small>
  
### *httpd* service

This service provides the web server to house the front-end components for the entire stack. All services that include a front-end UI component are built as a subdirectory under the main document root. The service is based on Apache2 webserver. The files stored in this directory are used to configure each component.

Each subsystem/subdirectory contains a *settings/settings.json* file, which define the behavior of the webapplication.

The certificates for the webserver are also stored in the */cert/server.\** files.

The certificates included in this repo are for localhost only, and you will need to replace these with your own real certificates.



### *wildfly* service

A combination of several services into a single WildFly instance.

The wildfly container supports several back-end services. The `psama` service for authentication (the **PIC-SURE Auth Microapp** component). It is also the back-end service for the `psamaui` front-end service, which is part of the `httpd` container.

The `picsure` service for accessing various data sources via queries. It is also the back-end service for the `picsureui` front-end service, which is also part of the `httpd` container.

In this stack, it also has the `picsure-irct-resource` service, to provide access to an i2b2 instance (if it has been configured to allow access to).

The configuration is stored in the standalone.xml file, which is placed at the standard path of */usr/local/wildfly/standalone/configuration/standalone.xml* on the container.



F
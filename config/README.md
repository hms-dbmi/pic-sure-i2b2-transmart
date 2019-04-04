
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

## i2b2/tranSmart

i2b2/tranSmart is a Java application, running on a Tomcat application server. Files configured are *Config.groovy* and *DataSource.groovy*.

###  variables
Name | Description | Sample Value
-----|-------------|------------------
`TM_EMAIL_NOTIFY` | Valid email address, that will receive notifications from the app about user interactions |  
`TM_ADMIN_EMAIL`| Valid e-mail address, used for notifications sent by the app.|
`TM_CONTACT_US`| Valid e-mail used in the *Contact Us* menu option of the app.|
`TM_OAUTH_SERVICE_URL` | external authentication service URL | http:/
`TM_OAUTH_LOGIN_URL` | second part of the endpoint for oAuth token introspection. Together with `TM_OAUTH_SERVICE_URL`, it is used to validate users via PSAMA service. | /psama/login
`TM_OAUTH_SERVICE_TOKEN` | Token provided by the PSAMA service, to be used by the application to authenticate requests. | 
`TM_OAUTH_SERVICE_APP_ID` | UUID provided by the PSAMA service, to specify which application is using its services. | 1111b111-1111-1111-11aa-1a11111aaa11
`TM_SOLR_HOST` | Host and port for the solr service used by the app. | localhost:8983
`TM_SOLR_BASE_URL` | URL used by the app, to redirect users, for *solr* endpoint. | http://localhost:8983
`TM_GRAILS_MAIL_HOST` | Hostname of the smtp mail service. | smtp.gmail.com
`TM_GRAILS_MAIL_USERNAME` | Username for the smtp mail service. | 
`TM_GRAILS_MAIL_PASSWORD` | Password for the smtp mail service. |


# fractalis

Fractalis is a python based back-end service for the fractalis i2b2/tranSmart plugin. In conjunction with `worker`, `redis` and `rabbitmq` services, it interacts with datasources, to produce a rich data exploration environment.

The *docker-compose.yml* file sets up the path inside the container for the *config.py* file, where configuration variables are stored. 

### variables

Name | Description | Sample Value
-----|-------------|------------------
`AUTH_CLIENT_SECRET` | Authentication secret used for secure communication with available datasources |


# httpd

This service provides the web server to house the front-end components for the entire stack. All services that include a front-end UI component are built as a subdirectory under the main document root. The service is based on Apache2 webserver. The files stored in this directory are used to configure each component.

Each subsystem/subdirectory contains a *settings/settings.json* file, which define the behavior of the webapplication. 

### `psamaui` variables
Name | Description | Sample Value
-----|-------------|------------------
`AUTH0_CLIENT_ID` | Client ID for authentication purposes. |

### `picsureui` variables
Name | Description | Sample Value
-----|-------------|------------------
`PICSURE_APP_UUID` | The `psama` application UUID, once configured | 00000000-0000-0000-0000-000000000000

The certificates for the webserver are also stored in the */cert/server.\** files. 

The certificates included in this repo are for localhost only, and you will need to replace these with your own real certificates.

# wildfly

The wildfly container supports several back-end services. The `psama` service for authentication (the **PIC-SURE Auth Microapp** component). It is also the back-end service for the `psamaui` front-end service, which is part of the `httpd` container. 

The `picsure` service for accessing various data sources via queries. It is also the back-end service for the `picsureui` front-end service, which is also part of the `httpd` container. 

In this stack, it also has the `picsure-irct-resource` service, to provide access to an i2b2 instance (if it has been configured to allow access to).

The configuration is stored in the standalone.xml file, which is placed at the standard path of */usr/local/wildfly/standalone/configuration/standalone.xml* on the container. 

The file requires the below variables to be set before starting up the container.

### `psama` variables

Name | Description | Sample Value
-----|-------------|------------------
`PSAMA_AUTH_CLIENT_ID`|__PSAMA_AUTH_CLIENT_ID__
`PSAMA_AUTH_CLIENT_SECRET`|__PSAMA_AUTH_CLIENT_SECRET__
`PSAMA_CLIENT_ID`| | 
`PSAMA_CLIENT_SECRET`| | 
`PSAMA_CLIENT_SECRET_IS_BASE_64`| boolean value to state if the secret is base64 encoded or not | `false`
`PSAMA_DB_HOST`| the IP address of the MySQL database | `127.0.0.1` 
`PSAMA_DB_PORT`| the port where MySQL service is listening on | `3306` 
`PSAMA_DB_NAME`| the name of the database on the MySQL server | `auth` 
`PSAMA_DB_USERNAME`| username to access the database | `root` 
`PSAMA_DB_PASSWORD`| password for accessing the database | `password` 
`PSAMA_GMAIL_FROM_EMAIL`| email that will appear on messages received from the authorization service | `user@gmail.com` 
`PSAMA_GMAIL_USERNAME`| the username to access the gMail service | 
`PSAMA_GMAIL_PASSWORD`| the password for sending e-mails via gMail | 
`PSAMA_TOS_ENABLED`| is TermsOfService enabled, boolean | `false` 
`PSAMA_USER_ACTIVATION_REPLY_TO`| URL endpoint to reply with activation messages | `/psama/activation` 
`PSAMA_USER_ACTIVATION_TEMPLATE_PATH`| | 
`PSAMA_SYSTEM_NAME`| the name to identify this PIC-SURE API | `pic-sure` 


### `picsure` variables

Name | Description | Sample Value
-----|-------------|------------------
`PICSURE_CLIENT_SECRET`| |
`PICSURE_DB_HOST`| the MySQL database IP address | `127.0.0.1`
`PICSURE_DB_PORT`| the port where MySQL database is listening on | `3306`
`PICSURE_DB_NAME`| the name of the MySQL database | `picsure`
`PICSURE_DB_USERNAME`| username for accessing the MySQL database | `root`
`PICSURE_DB_PASSWORD`| password for accessing the MySQL databae | `password`
`PICSURE_IRCT_TARGET_URL`| the URL endpoint where the IRCT service is receiving requests | `http://httpd/irct`
`PICSURE_TOKEN_INTROSPECTION_TOKEN_PS2`| |
`PICSURE_TOKEN_INTROSPECTION_URL`| |
`PICSURE_USERID_CLAIM`| the JWT claim to take user identification from | `sub`

## IRCT

If the `IRCT` service is required, the configuration of its _standalone.xml_ file can be found in the _templates/irct/wildfly/standalone/configure/standalone.xml_ path of this repo.

The following variables will need to be changed.

Name | Description | Sample Value
-----|-------------|------------------




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
├── psama
│   └── standalone
│       └── configuration
│           └── standalone.xml
├── picsure
│   └── standalone
│       └── configuration
│           └── standalone.xml
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
`AUTH0_CLIENT_ID` | Client ID for authentication purposes. |

# psama

This service is the back-end portion of the **PIC-SURE Auth Microapp** component. The front-end component, referred to as `psamaui`, is part of the `httpd` service (see above).

The service is a Java based application, running on a WildFly application server. The configuration is stored in the standalone.xml file, which is placed at the standard path of *wildfly/standalone/configuration/standalone.xml*

### variables
Name | Description | Sample Value
-----|-------------|------------------
`DB_HOST` | The DNS name or IP address of the MySQL database, where the configuration data is stored. The database name is `auth` and stores information, such as resource definitions, query parameters for each user and some user information |
`DB_PORT` | The port where the MySQL database is listenting on. | 3306
`DB_USER` | The username for the MySQL database. |
`DB_PASSWORD`| The password, corresponding to the `DB_USER` username for the MySQL database |

# picsure

This service is the back-end portion of **PIC-SURE UI** component. It provides query capabilities to several configured data sources, with authentication, auditing and authorization capabilities.

### variables
Name | Description | Sample Value
-----|-------------|------------------
`DB_HOST` | The DNS name or IP address of the MySQL database, where the configuration data is stored. The database name is `picsure` and stores information, such as resource definitions, query parameters for each user and some user information |
`DB_PORT` | The port where the MySQL database is listenting on. | 3306
`DB_USER` | The username for the MySQL database. |
`DB_PASSWORD`| The password, corresponding to the `DB_USER` username for the MySQL database |

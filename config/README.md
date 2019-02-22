
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

i2b2/tranSmart is a Java application, running on a Tomcat application server.

###  variables
Name | Description | Sample Value
-----|-------------|------------------
`TM_EMAIL_NOTIFY` | A valid email address, that will receive notifications from the app about user interactions |  
`TM_ADMIN_EMAIL`| |
`TM_CONTACT_US`| |
`TM_OAUTH_SERVICE_URL` | external authentication service URL | http:/
`TM_OAUTH_LOGIN_URL` | | /psama/login
`TM_OAUTH_SERVICE_TOKEN` | | 
`TM_OAUTH_SERVICE_APP_ID` | | 1111b111-1111-1111-11aa-1a11111aaa11
`TM_SOLR_HOST` | | localhost:8983
`TM_SOLR_BASE_URL` | | http://localhost:8983
`TM_GRAILS_MAIL_HOST` | | smtp.gmail.com
`TM_GRAILS_MAIL_USERNAME` | | 
`TM_GRAILS_MAIL_PASSWORD` | |


# fractalis

Fractalis is a python based back-end service for the fractalis i2b2/tranSmart plugin. In conjunction with `worker`, `redis` and `rabbitmq` services, it interacts with datasources, to produce a rich data exploration environment

### variables

Name | Description | Sample Value
-----|-------------|------------------
`AUTH_CLIENT_SECRET` | Authentication secret used for secure communication with available datasources |


# httpd

This service provides the web server to house the front-end components for the entire stack. All services that include a front-end UI component are built as a subdirectory under the main document root. The service is based on Apache2 webserver. The files stored in this directory are used to configure each component.

### `psamaui` variables

### `picsureui` variables

# psama

This service is the back-end portion of the **PIC-SURE Auth Microapp** component. The front-end component, referred to as `psamaui`, is part of the `httpd` service (see above).

The service is a Java based application, running on a WildFly application server. The configuration is stored in the standalone.xml file, which is placed at the standard path of 

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





## standalone.xml

The configuration file for a standalone Wildfly server is standalone.xml

This file contains configuration for the application server itself in
addition to configuration specific to the applications being hosted.

The configuration of the application server itself is documented by
the maintainers of the Wildfly project. In a production setting, you
may need to adjust this configuration, the circumstances where this
might become necessary are outside the scope of this document.

The application specific configuration in a J2EE server is provided through
the JNDI mechanism. JNDI is effectively a type of key-value store where keys
are called names and values can be any Java object.

The JNDI configuration points you should be aware of in this file are outlined
below. Note that since the standalone.xml file is an XML document, it can
be fairly verbose. The parts you are required to modify for your environment
are in *bold*. You may need to modify other parts of the configuration if 
your particular environment has special performance or security concerns.

There are 2 Java web appplications hosted in the Wildfly container. 

The **PIC-SURE API v2** application serves, secures, and logs
queries to the HPDS datastore. PIC-SURE API v2 can also be configured
to support any number of other PIC-SURE API v2 compliant resources, but
this configuration is outside the scope of this document.

The **PIC-SURE Auth Micro-App**(psama) manages user access and provides RFC-7662
authorization and authentication services to PIC-SURE API v2. 

#### Datasources (standalone.xml)

Both of the J2EE applications use JPA to persist data in a relational
database. This example configuration assumes you are using MySQL as your
database server, but you can adapt this configuration to other database
servers. 

The PIC-SURE API v2 datasource is configured under the jndi-name "java:jboss/datasources/PicsureDS".

You must configure the following entries, if you are unsure what should go in here talk to the system administrator who deployed your MySQL server:

**__PDS_MYSQL_URL__** : Enter the IP or DNS name of your MySQL server. If you are using another database server you will need to find the correct configuration for a jdbc URL specific to your chosen database server.
**__PDS_MYSQL_PORT__** : Enter the TCP port your MySQL server listens on. The default is typically 3306, but your environment may be different.
**__PDS_MYSQL_USERNAME__** : Enter the username to be used by PIC-SURE API v2.
**__PDS_MYSQL_PASSWORD__** : Enter the password to be used by PIC-SURE API v2.

```<datasource jndi-name="java:jboss/datasources/PicsureDS" pool-name="PicsureDS" use-java-context="true">
    <connection-url>jdbc:mysql://__PDS_MYSQL_URL__:__PDS_MYSQL_PORT__/picsure?useUnicode=true&amp;characterEncoding=UTF-8&amp;autoReconnect=true&amp;autoReconnectForPools=true</connection-url>
    <driver>mysql</driver>
    <pool>
        <min-pool-size>5</min-pool-size>
        <max-pool-size>50</max-pool-size>
        <prefill>true</prefill>
    </pool>
    <security>
        <user-name>__PDS_MYSQL_USERNAME__</user-name>
        <password>__PDS_MYSQL_PASSWORD__</password>
    </security>
    <validation>
        <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker"/>
        <check-valid-connection-sql>SELECT 1</check-valid-connection-sql>
        <validate-on-match>true</validate-on-match>
        <background-validation>false</background-validation>
        <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter"/>
    </validation>
</datasource>
```
The PIC-SURE Auth Micro-App datasource is configured under the jndi-name "java:jboss/datasources/AuthDS".

You must configure the following entries, if you are unsure what should go in here talk to the system administrator who deployed your MySQL server:

**__AUTH_MYSQL_URL__** : Enter the IP or DNS name of your MySQL server. If you are using another database server you will need to find the correct configuration for a jdbc URL specific to your chosen database server.
**__AUTH_MYSQL_PORT__** : Enter the TCP port your MySQL server listens on. The default is typically 3306, but your environment may be different.
**__AUTH_MYSQL_USERNAME__** : Enter the username to be used by PIC-SURE API v2.
**__AUTH_MYSQL_PASSWORD__** : Enter the password to be used by PIC-SURE API v2.

```<datasource jndi-name="java:jboss/datasources/AuthDS" pool-name="AuthDS" use-java-context="true">
    <connection-url>jdbc:mysql://__AUTH_MYSQL_URL__:__AUTH_MYSQL_PORT__/auth?useUnicode=true&amp;characterEncoding=UTF-8&amp;autoReconnect=true&amp;autoReconnectForPools=true</connection-url>
    <driver>mysql</driver>
    <pool>
        <min-pool-size>5</min-pool-size>
        <max-pool-size>50</max-pool-size>
        <prefill>true</prefill>
    </pool>
    <security>
        <user-name>__AUTH_MYSQL_USERNAME__</user-name>
        <password>__AUTH_MYSQL_PASSWORD__</password>
    </security>
    <validation>
        <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker"/>
        <check-valid-connection-sql>SELECT 1</check-valid-connection-sql>
        <validate-on-match>true</validate-on-match>
        <background-validation>false</background-validation>
        <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter"/>
    </validation>
</datasource>
```


#### Application Settings (standalone.xml)

Both of the J2EE applications require some configuration that is specific to your
environment. Currently this is handled in the naming subsystem configuration of the
standalone.xml file. 

You must configure the following entries in the naming subsystem configuration of 
the standalone.xml file. If you are unsure what should go in here talk to a system 
administrator at your institution.

```
<bindings>
    <simple name="java:global/verify_user_method" value="tokenIntrospection"/>
    <simple name="java:global/token_introspection_url" value=" "/>
    <simple name="java:global/token_introspection_token" value="__PSAMA_TOKEN__"/>
    <simple name="java:global/user_id_claim" value="sub"/>
    <simple name="java:global/auth0host" value="https://avillachlab.auth0.com"/>
    <simple name="java:global/systemName" value="nothing"/>
</bindings>
```






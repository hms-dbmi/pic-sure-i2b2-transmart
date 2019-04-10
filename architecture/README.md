# i2b2/tranSMART 19.1 M1 Architectural Overview

## Introduction

The i2b2/tranSMART 19.1 M1 release serves as a production deployment reference
for an integrated research environment comprised of the following user-facing 
tools:

i2b2 - https://i2b2.org
tranSMART - https://transmartfoundation.org
Fractalis - https://fractalis.lcsb.uni.lu/
PIC-SURE UI - https://github.com/hms-dbmi/pic-sure-ui
PIC-SURE API - https://github.com/hms-dbmi/pic-sure
PIC-SURE Auth Micro-App - https://github.com/hms-dbmi/pic-sure-auth-microapp

Additionally, the following backend services which are configured as part of the
release are used by the above user-facing tools to provide functionality to users:

RabbitMQ - https://www.rabbitmq.com/
Redis - https://redis.io/

The following services not maintained as part of the release are considered
external dependencies of the environment. Deployment and configuration of these 
dependencies will vary across runtime environments due to considerations which
are out of scope for the i2b2/tranSMART release cycle. The technical expertise to 
deploy, configure, secure and maintain these systems is considered a prerequisite 
for handling large-scale patient level data. Additionally, with the necessary
expertise, these systems can be interchanged with equivalent alternatives. Such
implementation choices and the consdierations for each are not part of this 
reference, but there is a section for each to document assumptions and specify 
supported versions.

Oracle DBMS - https://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html?intcmp=ocom-hp-0219
MySQL - https://dev.mysql.com/
Auth0 - https://auth0.com
Docker - https://docker.com

## A note about Docker

The i2b2/tranSMART 19.1 M1 release is expressed as a docker-compose service stack,
but use of Docker for deployment is not required to stand up the release.

A docker-compose.yml file such as is used in this release is an expression of
network topology, directory mapping, firewall configuration and distributed
system deployment. In addition to this providing an entry-point for deployment,
this serves as an infrastructure-as-code reference for the architecture.

A docker-compose stack is a set of docker-compose service definitions. The service
definition abstraction is also used in the i2b2/tranSMART 19.1 M1 release to move
configuration files and deployment artifacts to their necessary locations in order
to configure the system.

By reading and understanding the docker-compose.yml file, the same controls and
configurations can be mapped to any other architecture. 

### Network topology as described by the docker-compose file

The docker-compose file specifies two network segments. Within a docker environment, the
network segments are implemented as host-level iptables routing configurations. In a
non-docker environment these network segments would be configured using separate subnets
segmented by firewall rules. 

Network segments in the reference docker-compose file:

public - This is used to expose port 443 for all incoming network traffic and port 80 for redirecting to port 443.
private - This is used for communication between services in the infrastructure.

The reason for exposing only the HTTPD container and only through port 443 is to limit
the network available attack surface of the stack to the HTTPD container and any service 
paths configured through its proxy configuration.

### Directory mapping as described by the docker-compose file

The docker-compose file specifies a variety of host-mapped volumes. These volumes
express files and folders that are overlayed on top of the file system view that
the service containers run within. This allows us to configure environment specific
settings and files external to the docker-compose service stack without using
environment variables or command line arguments. Environment variables are very commonly 
exposed through log files on system startup or as part of exception handling so using
them to configure secrets such as database passwords can result in the log backups becoming
a security liability. Command line arguments may be viewable to anyone with shell access
to the system, which includes any process running on the system. Due to the numerous
arbitrary code execution and privilege escalation vulnerabilities that are discovered
seemingly every day in the modern computing age, passing anything sensitive on the command 
line should not be considered safe no matter how well you think you locked down shell access.

The docker-compose file for this production deployment reference maps all volumes to
the host root path of /usr/local/docker-config so that there is a common path on the
host where all configurations and logs can be managed. Mounting this path on an encrypted
filesystem and managing the keys for that filesystem following the guidelines laid out in
NIST SP 800-88 is a best practice, especially in cloud hosted or on-premise virtualized 
environments. 

Volume mounted path organization in the reference docker-compose file:

| Host Path | Relevant Containers|
|:----------|:------------------:|
|/usr/local/docker-config/httpd|httpd|
|/usr/local/docker-config/transmart|transmart|
|/usr/local/docker-config/fractalis|fractalis, worker|
|/usr/local/docker-config/i2b2-wildfly/wildfly|i2b2-wildfly|
|/usr/local/docker-config/wildfly|wildfly, copy-pic-sure-war, copy-pic-sure-irct-resource, copy-pic-sure-auth-war, copy-irct|

### Firewall configuration as described by the docker-compose file 

There are two entries that can be added to a docker-compose service configuration 
to manage the firewall abstraction provided by docker. The *expose* entry declares
that containers within the docker-compose stack are able to reach the specified port
for the service. The *ports* entry declares how a port should be made available through
the docker host network interfaces. These mechanisms are well documented in the 
docker-compose documentation, if you wish to modify the configuration for your
environment, please refer to the docker-compose documentation which is publically
available.















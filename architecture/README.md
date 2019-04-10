# i2b2/tranSMART 19.1 M1 Platform Architectural Overview

## Introduction

The i2b2/tranSMART 19.1 M1 Platform release serves as a production deployment 
reference for an integrated research environment comprised of the following 
user-facing tools:

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

The docker-compose file specifies two *networks* entries. Within a docker environment, the
network segments are implemented by the docker engine as host-level iptables routing configurations. 
In a non-docker environment these network segments would be configured using separate subnets
segmented by firewall rules. 

Network segments in the reference docker-compose file:

public - This is used to expose port 443 for all incoming network traffic and port 80 for redirecting to port 443.
private - This is used for communication between services in the infrastructure.

The reason for exposing only the HTTPD container and only through port 443 is to limit
the network available attack surface of the stack to the HTTPD container and any service 
paths configured through its proxy configuration.

### Directory mapping as described by the docker-compose file

The docker-compose file specifies a variety of host-mapped *volumes*. These volumes
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

### Distributed system deployment as described by the docker-compose file

The i2b2/tranSMART 19.1 Platform is a distributed system. It is composed of several
independently managed processes working together to provide a set of functionality
to users. The docker-compose stack results in the majority of the system being deployed
on a single compute node, however the network topology and container isolation abstractions
provided by docker result in the system behaving as if it were distributed across many
different machines.

This perspective on the system that it is distributed is essential to properly troubleshoot,
performance tune, and scale the i2b2/tranSMART 19.1 Platform.

Each docker-compose service should be viewed as a separate node in the distributed system. The
dependencies of each service are expressed in the docker-compose *depends_on* entries.

Nodes in the i2b2/tranSMART 19.1 Platform as a distributed system and their dependency relationships
as managed within the docker-compose stack:

*note: only services which have dependencies within the docker-compose service stack have entries in this table*

|Service Node|Dependency Services|
|:-----------|:-----------------:|
|httpd|wildfly,transmart,fractalis|
|transmart|wildfly,fractalis,solr,|
|fractalis|redis,rabbitmq,worker|
|worker|redis,rabbitmq,wildfly|
|wildfly|i2b2-wildfly,copy-pic-sure-war,copy-pic-sure-auth-war,copy-pic-sure-irct-resource,copy-irct|

Additionally, external dependencies such as Auth0, the DBMS housing the i2b2 data warehouse and tranSMART
specific schemas and the DBMS hosting the application specific databases for PIC-SURE services should be
considered nodes in the distributed system as well. These components and their management are external
to the i2b2/tranSMART 19.1 release. Configuration and provisioning of these services should be done
in accordance with the guidelines of your institution's IT department.

Nodes in teh i2b2/tranSMART 19.1 Plaftorm as a distributed system and their dependency relationships
which must be managed externally to the docker-compose stack and production deployment reference:

|External Service|Dependent docker-compose Services|
|:---------------|:-------------------------------:|
|Auth0|wildfly, httpd|
|Oracle DB|i2b2-wildfly,transmart|
|MySQL DB|wildfly|

### Wildfly service deployment notes

The copy-pic-sure-war, copy-pic-sure-irct-resource, copy-pic-sure-auth-war and copy-irct docker-compose
service definitions are configured to copy the necessary deployment artifacts from each Java 11 compatible
J2EE web application from the published standalone images into a single Wildfly instance's deployment directory. 

These web applications work as a pipeline of sorts to provide data to users in expected formats, audit data
access and authorize requests. As data flows across these web applications the memory used to store a dataset
at each step is required to be available for each application. Because a JVM must have enough heapspace to
store the largest working set it will ever expect to have in memory, without this consolidation onto a
single container this memory requirement would have to be met separately for each of these applications.

By deploying these applications to a single wildfly instance, the heap memory freed as one application finishes
its job with a dataset can be used by the next application in the pipeline. This effectively cuts the memory
requirement in half for this set of web applications. Additionally, since each wildfly instance and each JVM
process uses some memory by itself without any web applications being deployed, we actually save more
memory by doing this than just the elastic working set of our data pipeline. 










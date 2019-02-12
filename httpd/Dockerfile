FROM dbmi/pic-sure-hpds-ui-udn:jason_udn_deployment_8d6a5c8 AS picsure-ui
#FROM dbmi/pic-sure-hpds-ui:18.1-Quickstart-v2 AS picsure-ui
FROM dbmi/pic-sure-auth-ui:picsure-185-auth0-integration_70274e4 AS picsure-admin-ui

FROM httpd:2.4.27-alpine

RUN apk add --update openssl sed

# Replace virtual host config file with ours
COPY httpd-vhosts.conf ${HTTPD_PREFIX}/conf/extra/httpd-vhosts.conf

# Enable virtual hosting config file
RUN sed -i '/^#Include conf.extra.httpd-vhosts.conf/s/^#//' ${HTTPD_PREFIX}/conf/httpd.conf

# Enable necessary proxy modules
RUN sed -i '/^#LoadModule proxy_module/s/^#//' ${HTTPD_PREFIX}/conf/httpd.conf
RUN sed -i  '/^#LoadModule proxy_http_module/s/^#//' ${HTTPD_PREFIX}/conf/httpd.conf
RUN sed -i '/^#LoadModule proxy_connect_module/s/^#//' ${HTTPD_PREFIX}/conf/httpd.conf

#### SSL ####
# enable ssl
RUN sed -i '/^#LoadModule ssl_module modules\/mod_ssl.so/s/^#//' ${HTTPD_PREFIX}/conf/httpd.conf
RUN sed -i '/^#LoadModule rewrite_module modules\/mod_rewrite.so/s/^#//' ${HTTPD_PREFIX}/conf/httpd.conf
RUN sed -i '/^#LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/s/^#//' ${HTTPD_PREFIX}/conf/httpd.conf
RUN mkdir /usr/local/apache2/logs/ssl_mutex

COPY --from=picsure-admin-ui /usr/local/apache2/htdocs ${HTTPD_PREFIX}/htdocs/psama
COPY --from=picsure-ui /usr/local/apache2/htdocs ${HTTPD_PREFIX}/htdocs/picsureui

# Temporary fix for picsureui
COPY extras/index.html ${HTTPD_PREFIX}/htdocs/picsureui
COPY extras/main3.js ${HTTPD_PREFIX}/htdocs/picsureui
COPY extras/login.hbs ${HTTPD_PREFIX}/htdocs/picsureui/hpds

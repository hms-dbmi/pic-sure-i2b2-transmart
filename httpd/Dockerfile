FROM dbmi/pic-sure-ui:ui_fix_f8b24b0 AS picsureui
#FROM dbmi/psama-ui:3dea3ede AS psamaui
FROM dbmi/pic-sure-auth-ui:jason_udn_deployment_4293a8d AS psamaui

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

COPY --from=psamaui /usr/local/apache2/htdocs ${HTTPD_PREFIX}/htdocs
COPY --from=picsureui /usr/local/apache2/htdocs ${HTTPD_PREFIX}/htdocs/picsureui

#COPY psamaui_login_login.js ${HTTPD_PREFIX}/htdocs/psamaui/login/login.js

FROM centos:centos6
MAINTAINER Integria IMS Team <info@integriaims.com>

RUN { \
	echo '[EPEL]'; \
	echo 'name = CentOS Epel'; \
	echo 'baseurl = http://dl.fedoraproject.org/pub/epel/6/x86_64'; \
	echo 'enabled=1'; \
	echo 'gpgcheck=0'; \
} > /etc/yum.repos.d/extra_repos.repo

RUN yum -y update; yum clean all;
RUN yum install -y \ 
	httpd \
	php \
	php-cli \
	php-gd \
	php-intl \
	php-ldap \
	php-imap \
	php-mysql \
	php-mbstring
	
EXPOSE 80

# Simple startup script to avoid some issues observed with container restart
ADD docker_entrypoint.sh /entrypoint.sh
RUN chmod -v +x /entrypoint.sh

CMD ["/entrypoint.sh"]


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
	git \
	httpd \
	cronie \
	ntp \
	openldap \
	wget \
	curl \
	openldap \
	mysql \
	php \
	php-cli \
	php-gd \
	php-intl \
	php-ldap \
	php-imap \
	php-mysql \
	php-mbstring

#Clone the repo
RUN git clone -b master https://github.com/articaST/integriaims.git /tmp/integriaims

#Exposing ports for: SSH, HTTP and Tentacle
EXPOSE 22 80 41121

# Simple startup script to avoid some issues observed with container restart
ADD docker_entrypoint.sh /entrypoint.sh
RUN chmod -v +x /entrypoint.sh

CMD ["/entrypoint.sh"]


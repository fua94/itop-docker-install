FROM centos:centos6

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

EXPOSE 22
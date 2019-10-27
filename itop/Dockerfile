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
	httpd \
	php \
	php-mysql \
	php-xml \
	php-cli \
	php-soap \
	php-ldap \
	php-gd \
	php-zip \
	php-json \
	php-mbstring \
	graphviz
	
RUN systemctl enable httpd.service

EXPOSE 80


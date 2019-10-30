FROM centos:centos6

RUN yum -y update; yum clean all;
RUN yum install -y epel-release
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

RUN yum install -y \ 
	httpd \
	graphviz
	
RUN yum --enablerepo=remi-php72 install -y \
	php \
	php-mysql \
	php-xml \
	php-cli \
	php-soap \
	php-ldap \
	php-gd \
	php-zip \
	php-json \
	php-mbstring

EXPOSE 80

RUN rm -f /var/www/html/*
COPY app /var/www/html/
RUN chown -R apache:apache /var/www/html/ 

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

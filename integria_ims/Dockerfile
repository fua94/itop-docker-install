FROM centos:centos6

RUN yum -y update; yum clean all;
RUN yum install -y epel-release
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

RUN yum install -y httpd 
	
RUN yum --enablerepo=remi-php72 install -y \
	php \
	php-cli \
	php-gd \
	php-intl \
	php-ldap \
	php-imap \
	php-mysql \
	php-mbstring

EXPOSE 80

RUN rm -f /var/www/html/*
COPY app /var/www/html/
RUN chown -R apache:apache /var/www/html/ 

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

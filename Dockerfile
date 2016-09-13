## Docker URL: https://hub.docker.com/r/laradock/phpnginx
#############################################################################
FROM phusion/baseimage:0.9.17

MAINTAINER Luizcoder <luiz@luizcoder.com.br>

# Default baseimage settings
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]
ENV DEBIAN_FRONTEND noninteractive

RUN add-apt-repository ppa:ondrej/php5-5.6 -y

RUN apt-get update \
    && apt-get install -y --force-yes \
    nginx \
    php5 \
    php5-fpm \
    php5-cli \
    php5-mysql \
    php5-mcrypt \
    php5-curl \
    php5-gd \
    php5-intl \
    mysql-server

RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
              /tmp/* \
              /var/tmp/*

# Configure nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i "s/sendfile on/sendfile off/" /etc/nginx/nginx.conf
RUN mkdir -p /var/www

# Configure PHP
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = America\/Sao_Paulo/" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = America\/Sao_Paulo/" /etc/php5/cli/php.ini
RUN php5enmod mcrypt

# Configure Mysql and add configuration scripts
ADD build/mysql/my.cnf /etc/mysql/conf.d/my.cnf 
ADD build/mysql/run.sh /usr/local/bin/mysql-run
RUN chmod +x /usr/local/bin/mysql-run


# Add composer
RUN curl http://getcomposer.org/composer.phar > /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Add start script
ADD build/start.sh /usr/local/bin/start-services
RUN chmod +x /usr/local/bin/start-services
CMD ["/usr/local/bin/start-services"]


VOLUME ["/var/www", "/etc/nginx/sites-available", "/etc/nginx/sites-enabled"]
WORKDIR /var/www


EXPOSE 80 3306

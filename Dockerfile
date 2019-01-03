FROM ubuntu:16.04

RUN apt-get clean && apt-get update && apt-get install -y locales
RUN export LANGUAGE=en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN export LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN usermod -u 1100 www-data
RUN apt-get install -y apache2 \
	wget \
	php	\
	libapache2-mod-php \
	libapache2-mod-php \
	php-common \
	php-mbstring \
	php-xmlrpc \
	php-soap \
	php-gd \
	php-xml \
	php-intl \
	php-mysql \
	php-cli \
	php-mcrypt \
	php-ldap \
	php-zip \
	php-curl \
	unzip

RUN rm /var/www/html/index.html

RUN mkdir -p /var/www/html/smf

#####################################################################################################
# RUN cd /var/www/html
# RUN wget https://download.simplemachines.org/index.php/smf_2-0-15_install.tar.gz -P /var/www/html
# RUN tar xfvz /var/www/html/smf_2-0-15_install.tar.gz -C /var/www/html/smf
# RUN chmod -R 777 /var/www/html/attachments/ \
# 	/var/www/html/avatars/ \
# 	/var/www/html/cache/ \
# 	/var/www/html/Packages/ \
# 	/var/www/html/Smileys/ \
# 	/var/www/html/Themes/ \
# 	/var/www/html/agreement.txt \
# 	/var/www/html/Settings.php \
# 	/var/www/html/Settings_bak.php
##########################################################################################################

RUN chown -R www-data:www-data /var/www/html/smf/
RUN chmod -R 755 /var/www/html/smf/

COPY ./config/apache2.conf /etc/apache2/apache2.conf
COPY ./config/ports.conf /etc/apache2/ports.conf
COPY ./config/smf.conf /etc/apache2/sites-available/smf.conf
COPY ./config/php.ini /etc/php/7.0/apache2/php.ini

RUN ln -sf /dev/stdout /var/log/apache2/access.log
RUN ln -sf /dev/stdout /var/log/apache2/error.log

RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn
RUN a2dissite *.conf && a2ensite smf.conf
RUN a2enmod rewrite

RUN apache2ctl restart

CMD /usr/sbin/apache2ctl -D FOREGROUND

EXPOSE 8080

#gitbox with gitlist v.0.5.0
FROM ubuntu:trusty
MAINTAINER Nick Marus <nmarus@gmail.com>

#Setup Container
VOLUME ["/repos"]
EXPOSE 80 443 9418

#update, install prerequisites, clean up apt
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git wget nginx-full php5-fpm fcgiwrap apache2-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get clean

#install gitlist
RUN mkdir -p /var/www && wget -q -O /var/www/gitlist-0.5.0.tar.gz https://s3.amazonaws.com/gitlist/gitlist-0.5.0.tar.gz
RUN tar -zxvf /var/www/gitlist-0.5.0.tar.gz -C /var/www && chmod -R 777 /var/www/gitlist
RUN mkdir -p /var/www/gitlist/cache && chmod 777 /var/www/gitlist/cache

#create config files for container startup, gitlist and nginx
COPY start.sh /start.sh
RUN chmod 755 /start.sh
COPY gitd /etc/init.d/gitd
RUN chmod 755 /etc/init.d/gitd
COPY repoadd.sh /usr/local/bin/repoadd.sh
RUN chmod 755 /usr/local/bin/repoadd.sh
COPY config.ini /var/www/gitlist/config.ini
COPY nginx.conf /etc/nginx/nginx.conf

#setup user account for gitd
RUN useradd -M -s /bin/false git

#setup services to run as user git
RUN sed -i 's/user = www-data/user = git/g' /etc/php5/fpm/pool.d/www.conf
RUN sed -i 's/group = www-data/group = git/g' /etc/php5/fpm/pool.d/www.conf
RUN sed -i 's/listen.owner = www-data/listen.owner = git/g' /etc/php5/fpm/pool.d/www.conf
RUN sed -i 's/listen.group = www-data/listen.group = git/g' /etc/php5/fpm/pool.d/www.conf
RUN sed -i 's/FCGI_USER="www-data"/FCGI_USER="git"/g' /etc/init.d/fcgiwrap
RUN sed -i 's/FCGI_GROUP="www-data"/FCGI_GROUP="git"/g' /etc/init.d/fcgiwrap
RUN sed -i 's/FCGI_SOCKET_OWNER="www-data"/FCGI_SOCKET_OWNER="git"/g' /etc/init.d/fcgiwrap
RUN sed -i 's/FCGI_SOCKET_GROUP="www-data"/FCGI_SOCKET_GROUP="git"/g' /etc/init.d/fcgiwrap

#setup default username and password for authentication
RUN htpasswd -cb /etc/nginx/htpasswd gitadmin gitsecret

CMD ["/start.sh"]

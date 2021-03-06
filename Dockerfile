#gitbox with gitlist v.0.5.0
FROM ubuntu:trusty
MAINTAINER Nick Marus <nmarus@gmail.com>

#Setup Container
VOLUME ["/repos"]

# SSL comes from nginx-proxy
EXPOSE 80

#update, install prerequisites, clean up apt
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
	apt-get -y install git wget nginx-full php5-fpm fcgiwrap apache2-utils && \
	apt-get clean

#setup git user for nginx
RUN useradd -M -s /bin/false git --uid 1000

#setup nginx services to run as user git, group git
RUN sed -i 's/user = www-data/user = git/g' /etc/php5/fpm/pool.d/www.conf && \
	sed -i 's/group = www-data/group = git/g' /etc/php5/fpm/pool.d/www.conf && \
	sed -i 's/listen.owner = www-data/listen.owner = git/g' /etc/php5/fpm/pool.d/www.conf && \
	sed -i 's/listen.group = www-data/listen.group = git/g' /etc/php5/fpm/pool.d/www.conf && \
	sed -i 's/FCGI_USER="www-data"/FCGI_USER="git"/g' /etc/init.d/fcgiwrap && \
	sed -i 's/FCGI_GROUP="www-data"/FCGI_GROUP="git"/g' /etc/init.d/fcgiwrap && \
	sed -i 's/FCGI_SOCKET_OWNER="www-data"/FCGI_SOCKET_OWNER="git"/g' /etc/init.d/fcgiwrap && \
	sed -i 's/FCGI_SOCKET_GROUP="www-data"/FCGI_SOCKET_GROUP="git"/g' /etc/init.d/fcgiwrap

#install gitlist
RUN mkdir -p /var/www && \
	wget -q -O /var/www/gitlist-0.5.0.tar.gz https://s3.amazonaws.com/gitlist/gitlist-0.5.0.tar.gz && \
	tar -zxvf /var/www/gitlist-0.5.0.tar.gz -C /var/www && \
	chmod -R 777 /var/www/gitlist && \
	mkdir -p /var/www/gitlist/cache && \
	chmod 777 /var/www/gitlist/cache

#create config files for container startup, gitlist and nginx
COPY config/start.sh /start.sh
COPY repoadd.sh /usr/local/bin/repoadd.sh
COPY repoclone.sh /usr/local/bin/repoclone.sh
COPY repodelete.sh /usr/local/bin/repodelete.sh
COPY config/config.ini /var/www/gitlist/config.ini
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/htpasswd /etc/nginx/htpasswd
RUN chmod 755 /start.sh && \
	chmod 755 /usr/local/bin/repo*.sh

CMD ["/start.sh"]

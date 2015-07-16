#!/bin/bash
dockername=gitbox

timestamp() {
  date +"%Y-%m-%d %T"
}

startc() {
  echo "$(timestamp): Services for ($dockername) are being started..."
  /etc/init.d/php5-fpm start > /dev/null
  /etc/init.d/fcgiwrap start > /dev/null
  /etc/init.d/nginx start > /dev/null
  /etc/init.d/gitd start > /dev/null
  echo "$(timestamp): The ($dockername) services have started..."  
}

stopc() {
  echo "$(timestamp): Services for ($dockername) are being stopped..."
  /etc/init.d/gitd stop > /dev/null
  /etc/init.d/nginx stop > /dev/null
  /etc/init.d/php5-fpm stop > /dev/null
  /etc/init.d/fcgiwrap stop > /dev/null
  echo "$(timestamp): Services for ($dockername) have successfully stopped..."
  echo "$(timestamp): Exiting..."
}

#trap "docker stop <container>"
trap "(stopc)" TERM

#startup
echo "$(timestamp): Container ($dockername) is starting..."

#create repo main folder
echo "$(timestamp): Checking if "repos" folder exists..."
if [ ! -e /repos ]; then
  mkdir /repos
fi

#Fix persmissions for repo 
chown git:git -R 777 /repos

#start services in background
startc

#pause script to keep container running...
echo "$(timestamp): [Hit enter key to stop] or run 'docker stop $dockername'"
read

#stop services
stopc

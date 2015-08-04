#!/bin/bash
dockername=gitbox

set -e

#description:   timestamp
#usage:         echo ${timestamp}
#returns:       timestamp

timestamp() {
        date +"%Y-%m-%d %T"
}

#description:   script logger
#usage:         sclog <message> [<file>]
#returns:       dated log message

sclog() {
        if [ ! -z ${2+x} ]; then
                #if $2 is existing character file or not exisiting
                if [ -c ${2} ] || [ ! -a ${2} ]; then
                        echo "$(timestamp): ${1}" | tee -a ${2}
                else
                        echo "$(timestamp): ${1}"
                fi
        else
                echo "$(timestamp): ${1}"
        fi
}

startc() {
  sclog "Services for ($dockername) are being started..."
  /etc/init.d/php5-fpm start > /dev/null
  /etc/init.d/fcgiwrap start > /dev/null
  /etc/init.d/nginx start > /dev/null
  sclog "The ($dockername) services have started..."  
}

stopc() {
  sclog "Services for ($dockername) are being stopped..."
  /etc/init.d/nginx stop > /dev/null
  /etc/init.d/php5-fpm stop > /dev/null
  /etc/init.d/fcgiwrap stop > /dev/null
  sclog "Services for ($dockername) have successfully stopped. Exiting."
}

#trap "docker stop <container>"
trap "(stopc)" TERM

#startup
sclog  "Container ($dockername) is starting..."

#create repo main folder
sclog  "Checking if "repos" folder exists..."
if [ ! -e /repos ]; then
  mkdir /repos
fi

#Fix persmissions for repo 
sclog  "Fixing permissions for "repos" folder..."
chown -R git:git /repos >& /dev/null
find /repos -type f -exec chmod 644 '{}' +

#start services in background
startc

#pause script to keep container running...
sclog "Services for container successfully started."
stop="no"
while [ "$stop" == "no" ]
do
sclog "Type [stop] or run 'docker stop $dockername' from host."
read input
if [ "$input" == "stop" ]; then stop="yes"; fi
done

#stop services
stopc

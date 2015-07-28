#!/bin/bash

DIR_NAME="$(dirname "$0")"

###check for docker-bash-functions.sh###
if [ -a ${DIR_NAME}/docker-bash-functions.sh ]; then
	source ${DIR_NAME}/docker-bash-functions.sh
else
	echo "docker-bash-functions.sh missing..."
	exit 1
fi

###check for docker.cfg###
if [ -a ${DIR_NAME}/docker.cfg ]; then
	source ${DIR_NAME}/docker.cfg
else
	echo "docker.cfg missing..."
	exit 1
fi

docker exec -it ${co} /bin/bash

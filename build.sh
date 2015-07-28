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

df="${DIR_NAME}/."

####Build New Image ###
echo "Building image '${im}' for container '${co}'..."
if $(dbuild ${im} ${df} "${bargs}"); then 
	echo "Image '${im}' successfully built."
else 
	echo "Image '${im}' failed to build!!! Exiting."
	exit 1
fi

####Start New Container####
echo "Starting container '${co}'..."
if $(drun ${co} ${im} "${rargs}"); then 
	echo "Container '${co}' started."
else 
	echo "Container '${co}' failed to start!!! Exiting."
	exit 1
fi

####Completed Successfully####
echo "Complete."

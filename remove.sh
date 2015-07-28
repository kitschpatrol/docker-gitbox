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

###Stop Container###
echo "Stopping container '${co}'..."
if $(dstop ${co}); then 
	echo "Container '${co}' successfully stopped."
else 
	echo "Container '${co}' failed to stop."
fi

###Remove Container###
echo "Removing container '${co}'..."
if $(drm ${co}); then 
	echo "Container '${co}' removed."
else 
	echo "Container '${co}' failed to be removed."
fi

###Remove Image###
echo "Removing image '${im}'..."
if $(drmi ${im}); then 
	echo "Image '${im}' removed."
else 
	echo "Image '${im}' failed to be removed."
fi

###Completed Successfully###
echo "Complete."

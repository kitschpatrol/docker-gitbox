###################################################################################
#Title		Docker bash functions
#Author		Nicholas Marus <nmarus@gmail.com>
#Updated	2015/7/26

#List of Docker functions

#is_object()	checks if referenced object exists in docker as image or container
#is_image()	    checks if referenced object is a image
#is_container()	checks if referenced object is a container
#is_running()	checks if referenced container is running
#dgetimage()	returns the image being used by the container
#dstart()       starts referenced container
#dstop()        stops referenced dontainer
#drm()		    removes referenced container if it is stopped
#drmf()         removes and if need stops referenced container
#drmi()         removes reference image
#drma()         removes all references to container and image
#dbuild()       builds docker image
#dcreate()      creates docker container from image
#drun()         creates and runs docker container from image
###################################################################################

#description:   Check if Docker object exists
#usage:        	is_object <name>
#returns:       0 for success, 1 for failure

is_object() {
	if $(docker inspect $1 >& /dev/null && true || false); then                
                #exists
                return 0
        else
                #does not exist
                return 1
        fi
}

#description:   Check if Docker object is an existing image
#usage:        	is_image <name>
#returns:       0 for success, 1 for failure

is_image() {
	if $(is_object $1); then
		#exists
		if [ "$(docker inspect -f "{{ .Architecture }}" $1 )" == "<no value>" ]; then                
			#is container
                	return 1
        	else
                	#is image
                	return 0
        	fi
	else
		#does not exist
		return 1
	fi
}

#description:   Check if Docker object is as an esiting container
#usage:        	is_container <name>
#returns:       0 for success, 1 for failure

is_container() {
        if $(is_object $1); then
                #exists
                if [ "$(docker inspect -f "{{ .Architecture }}" $1 )" == "<no value>" ]; then
                        #is container
                        return 0
                else
                        #is image
                        return 1
                fi
        else
                #does not exist
                return 1
        fi
}

#description:   Check if Docker container is running
#usage:        	is_running <name>
#returns:       0 for success, 1 for failure

is_running() {
        if $(is_container $1); then
                #exists as a container
                if $(docker inspect -f '{{ .State.Running }}' $1 ); then
                        #is running
                        return 0
                else
                        #is not running
                        return 1
                fi
        else
                #does not exist
                return 1
        fi
}

#description:   Get image name from container
#usage:        	dgetimage <container>
#returns:       image name for success

dgetimage() {
	if $(is_container $1); then
		#exists as a container
               	#return image name
               	echo $(docker inspect -f "{{ .Config.Image }}" $1)
	fi
}

#description:   Start Docker Container
#usage:        	dstart <container>
#returns:       0 for success, 1 for failure

dstart() {
	if $(is_container $1); then
        	#exists as a container
		if $(docker start $1 >& /dev/null && true || false); then
                	#success
                	return 0
        	else
			#fail
			return 1
		fi
	else
		#does not exist as a container
		return 1
	fi
}

#description:   Stop Docker Container
#usage:        	dstop <container>
#returns:       0 for success, 1 for failure

dstop() {
        if $(is_container $1); then
                #exists as a container
	        if $(docker stop $1 >& /dev/null && true || false); then
        	        #stop success
                	return 0
        	else
                	#stop fail
                	return 1
        	fi
	else
                #does not exist as a container
                return 1
        fi
}


#description:   Remove Docker Container if stopped
#usage:        	drm <container>
#returns:       0 for success, 1 for failure

drm() {
	if $(is_container $1); then
                #exists as a container
		if $(is_running $1); then
			#is running
			return 1
		else
			#is not running
			if $(docker rm $1 >& /dev/null && true || false); then
				#remove success
				return 0
			else
				#remove fail
				return 1
			fi
		fi
	else
		#does not exist as a container
		return 1
	fi
}


#description:   Remove Docker Container. Stop if needed.
#usage:        	drmf <container>
#returns:       0 for success, 1 for failure

drmf() {
        if $(is_container $1); then
                #exists as a container
                if $(is_running $1); then
                        #is running
                        if ( ! $(dstop $1) ); then
				            #stop fail
				            return 1
			             fi
                fi

                if $(drm $1); then
                    #remove success
                    return 0
                else
                    #remove fail
                    return 1
                fi
        else
            #does not exist as a container
            return 1
        fi
}


#description:   Remove Docker Image
#usage:        	drmi <image>
#returns:       0 for success, 1 for failure

drmi() {
	if $(is_image $1); then
		#exists as a image	
        if $(docker rmi $1 >& /dev/null && true || false); then
			#remove success
			return 0
		else
			#remove failure
			return 1
		fi
	else
		#does not exist as a image
		return 1
	fi
}


#description:   Remove Docker All (Container and Image)
#usage:         drma <container> [<image>]
#returns:       0 for success, 1 for failure

drma() {
    if $(is_container $1); then
        #exists as a container
        image=$(dgetimage $1) 
        #check if container is running
        if $(is_running $1); then
            #is running
            #stop and verify
            if ( ! $(dstop ${1}) ); then return 1; fi
        fi
        #remove and verify, exit on failure to remove.
        if ( ! $(drm ${1}) ); then return 1; fi
        #remove image associated with container.
        if $(is_image $image); then
            #remove image and verify, exit on failure to remove image.
            if $(drmi ${image}); then return 0; else return 1; fi
        fi
    fi
    if [ "$2" != "" ]; then
        #image variable passed
        #remove image if defined in $2
        if $(is_image $2); then
            #remove image and verify, exit on failure to remove image.
            if $(drmi ${2}); then return 0; else return 1; fi
        fi
    fi
    return 0
}

#description:   Build Docker Image
#usage:         dbuild <new image name> <path to Dockerfile> "<optional arg string>"
#returns:       0 for success, 1 for failure

#example:       #!/bin/sh
#example:       source functions.sh
#example:       BUILD_ARGS="--rm=true"
#example:       if $(dbuild myimage . "$BUILD_ARGS"); then
#example:               echo "Success"
#example:       else
#example:               echo "Fail"
#example:       fi

dbuild() {
        if ( ! $(is_image $1) ); then
                #does not exist as a image
                if [ "$3" == "" ]; then
                        #optional arguments not specified
                        if $(docker build -t ${1} ${2} >& /dev/null && true || false); then
                                #build success
                                return 0
                        else
                                #build fail
                                return 1
                        fi
                else
                        #optional arguments found
                        ARGS=($3)
                        if $(docker build -t ${1} "${ARGS[@]}" ${2} >& /dev/null && true || false); then
                                #create success
                                return 0
                        else
                                #create fail
                                return 1
                        fi
                fi
        else
                #image exists
                return 1
        fi
}


#description:   Create Docker Container
#usage:        	dcreate <new container name> <existing image> "<optional arg string>"
#returns:       0 for success, 1 for failure

#example:	#!/bin/sh
#example:	source functions.sh
#example: 	CREATE_ARGS="-p 8080:80"
#example: 	if $(dcreate mycontainer mycontainerimage "$CREATE_ARGS"); then
#example:       	echo "Success"
#example: 	else
#example:       	echo "Fail"
#example: 	fi

dcreate() {
	if ( ! $(is_container $1) ); then
		#does not exist as a container
 		if [ "$3" == "" ]; then
			#optional arguments not specified
			if $(docker create -it --name $1 $2 >& /dev/null && true || false); then
				#create success
				return 0
			else
				#create fail
				return 1
			fi
		else
			#optional arguments found
			ARGS=($3)
                        if $(docker create -it --name ${1} "${ARGS[@]}" ${2} >& /dev/null && true || false); then
				#create success
				return 0
			else
				#create fail
				return 1
			fi
		fi
	else
		#container exists
		return 1
	fi
}


#description:   Run Docker Container
#usage:        	drun <new container name> <existing image> "<optional arg string>"
#returns:       0 for success, 1 for failure

#example:       #!/bin/sh
#example:       source functions.sh
#example:       RUN_ARGS="-p 8080:80"
#example:       if $(drun mycontainer mycontainerimage "$RUN_ARGS"); then
#example:               echo "Success"
#example:       else
#example:               echo "Fail"
#example:       fi

drun() {
        if ( ! $(is_container $1) ); then
                #does not exist as a container
                if [ "$3" == "" ]; then
                        #optional arguments not specified
                        if $(docker run -d -it --name $1 $2 >& /dev/null && true || false); then
                                #run success
                                return 0
                        else
                                #run fail
                                return 1
                        fi
                else
                        #optional arguments found
                        ARGS=($3)
                        if $(docker run -d -it --name ${1} "${ARGS[@]}" ${2} >& /dev/null && true || false); then
                                #run success
                                return 0
                        else
                                #run fail
                                return 1
                        fi
                fi
        else
                #container exists
                return 1
        fi
}




GITBOX
======

*work in progress...*

GIT offers a [variety of protocols] (https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) to access a repository. This docker image is configured with the following access methods.

* git daemon
* git smart http (nginx)
* gitlist web (nginx)

*Note: Default Username and password for authentication have been set to gitadmin:gitsecret. See notes below about changing credentials. It is advised you reset the default credentails immediatly after installation.*

**To run from hub.docker.com image repository:**

From your docker host:

    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v /my/git/repo/directory:/repos nmarus/gitbox
    
**To run from github repository (Method 1):**

From your docker host:

    git clone -b stable https://github.com/nmarus/docker-gitbox.git
    cd docker-gitbox
    docker build --rm=true -t nmarus/gitbox .
    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v /my/git/repo/directory:/repos nmarus/gitbox
    
**To run from github repository (Method 2):**

From your docker host:

    git clone -b stable https://github.com/nmarus/docker-gitbox.git
    cd docker-gitbox
    ./build.sh

*Note: There are also scripts to remove the container and image as well as enter a bash shell...*

From your docker host you can run:

    ./remove.sh
    ./shell.sh


Server Repository Setup and Admin:
----------------------------------
After installing gitbox, the first thing you will want to do is add some repositories. This can eitehr be an empty repository, or an existing repository from another git server or [github.com.] (https://github.com)

To make this setup easier, gitbox allows an administrator to define these directly from the docker host without needing to access the shell of the containr, or have to worry about setting proper permissions on the files in the docker host's mapped volume. 

**To setup an empty repository from the docker host:**

    docker exec gitbox repoadd.sh <reponame>.git <description>
    
*example:*
    
    docker exec gitbox repoadd.sh myrepo.git "This is my first git repo."
    
**To clone an existing repository from another location:**

    docker exec gitbox repoclone.sh <url>
    
*example:*
    
    docker exec gitbox repoclone.sh https://github.com/nmarus/docker-gitbox.git
    
**To delete a gitbox repository:**

    docker exec gitbox repodelete.sh <reponame>.git //use with caution//
    
*example:*
    
    docker exec gitbox repodelete.sh docker-gitbox.git

Client / Server Connection:
---------------------------

**Setup client to use empty repository**

*Note: This example assumes you have created a empty repository (as show above) named "myrepo.git". This is intended to be executed from your git client command line inside the directory you wish to store the repository locally. See [Getting Started - Git Basics.] (https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)*

    mkdir myrepo
    cd myrepo
    git init
    git remote add origin http://192.168.10.52/git/myrepo.git
    git pull
    git checkout -b master
    touch README.md
    echo "##This is a README.md file.##" > README.md
    git add -A 
    git commit -m "This is my initial commit."
    git push --set-upstream origin master

**[Gitlist] (http://gitlist.org/) Browser Access:**

You can access git box using a internet browser. This utilizes the gitlist project. 

*Note: This example assumes you are running gitbox using the default docker mappings defined above. If not, adjust accordingly.*

Open an internet browser to **http://<docker host ip or hostname>** to access the gitlist interface and browse the repositories on gitbox.

*Note: If your repository's directory is empty, this url presents a blank page...*

**Git [Daemon] (https://git-scm.com/book/en/v2/Git-on-the-Server-Git-Daemon) Access:**

The git daemon running on gitbox allows access to the repository using the git:// protocol.

*Note: This example assumes you are running gitbox using the default docker mappings defined above. If not, adjust accordingly.*

    git clone git://<docker host ip or hostname>/myrepo.git
    
**Git [SMART-HTTP] (https://git-scm.com/book/en/v2/Git-on-the-Server-Smart-HTTP) Access:**

The git smart-http daemon running on git box allows a more traditional approach to accessing your repositories. This is similar to what most use with hosted repositories such as github.

    git clone http://<docker host ip or hostname>/git/myrepo.git
    
*Note: There is a slightly differnt url used in retrieving the git repository in this method. This is in contrast to the git:// protocol used by git daemon.*

**Authentication:**

The authentication method and interaction with git and gitlist is still a work in progress. This would *not* be considered a secure system at this point. That being said, some authentication is in place through modification to the nginx htpasswd file. 

    #clear (-c) password file and create (-b) initial creds
    docker exec gitbox htpasswd -cb /etc/nginx/htpasswd <user> <pass>
    #add (-b) additional users to existing password file
    docker exec gitbox htpasswd -b /etc/nginx/htpasswd <user> <pass>
    
News:
-----

*Change log 2015-7-27*

* Added repoclone option
* Added repodelete option
* Cleaned up start.sh
* Cleaned up Dockerfile

*Change log 2015-7-16*

* Added authentication options
* Fixed issue with 403 error
* Add bash script to create a repo on server with correct options. 

*Change log 2015-7-15*

* Added gitlist
* Added git daemon
* Added git smart http

*Open Items:*

* Add https setup for nginx
* Further tweak authentication between nginx and git smart-http

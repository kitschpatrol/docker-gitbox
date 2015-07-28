GITBOX
======

*work in progress...*

GIT offers a [variety of protocols] (https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) to access a repository.  Gitbox is a docker image that combines a preconfigured git server running git-daemon and git-smart-http services. This is complemented by an inatallation of gitlist. All of the web services are provided via nginx. 

Installation:
-------------

This requires docker to installed and operational. You can then either download this image from hub.docker.com, or clone this repository and build the image locally.

**To install and run from the hub.docker.com image repository:**

From your docker host:

    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v /my/git/repo/directory:/repos nmarus/gitbox
    
**To install and run from this github repository:**

From your docker host:

    git clone -b stable https://github.com/nmarus/docker-gitbox.git
    cd docker-gitbox
    docker build --rm=true -t nmarus/gitbox .
    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v </my/git/repo/directory>:/repos nmarus/gitbox


Server Repository Setup and Admin:
----------------------------------
After installing gitbox, the first thing you will want to do is add some repositories. This can either be an empty repository, or an existing repository from another git server such as [github.com.] (https://github.com)

To make this setup easier, gitbox allows an administrator to define the repositories directly from the docker host without needing to access the shell of the container or worry about setting proper permissions and security.

**To setup an empty repository:**

From your docker host:

    docker exec gitbox repoadd.sh <reponame>.git <description> [export]
    
*example:*
    
    docker exec gitbox repoadd.sh myrepo.git "This is my first git repo." export
    
*Note: Adding the optional 'export' keyword to this command marks the repository exportable for read-only access from git-daemon (git://[...]). If 'export' is not specified, then the repository must be authenticated to via git smart-http. 
    
**To clone an existing repository from another location:**

From your docker host:

    docker exec gitbox repoclone.sh <url> [export]
    
*example:*
    
    docker exec gitbox repoclone.sh https://github.com/nmarus/docker-gitbox.git export
    
*Note: Adding the optional 'export' keyword to this command marks the repository exportable for read-only access from git-daemon (git://[...]). If 'export' is not specified, then the repository must be authenticated to via git smart-http. 
    
**To delete a gitbox repository:**

From your docker host:

    docker exec gitbox repodelete.sh <reponame>.git //use with caution//
    
*example:*
    
    docker exec gitbox repodelete.sh docker-gitbox.git

Client / Server Connection:
---------------------------

**Setup client to use empty repository via http**

*Note: This example assumes you have created a empty repository (as show above) named "myrepo.git". This is intended to be executed from your git client's command line inside a directory you wish to store the repository locally. See [Getting Started - Git Basics.] (https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)*

From your docker client cli:

    mkdir myrepo
    cd myrepo
    git init
    git remote add origin http://<docker host ip or hostname>/git/myrepo.git
    git pull
    git checkout -b master
    touch README.md
    echo "##This is a README.md file.##" > README.md
    git add -A 
    git commit -m "This is my initial commit."
    git push --set-upstream origin master
    
*Note: This process will require authentication to the http server on clone, pull, or push. See Authentication.*

**[Gitlist] (http://gitlist.org/) Browser Access:**

You can access git box using a internet browser. This utilizes the gitlist project. 

*Note: This example assumes you are running gitbox using the default docker mappings defined above. If not, adjust accordingly.*

    http://<docker host ip or hostname>

*Note: If your repository's directory is empty, this url presents a blank page...*

**Git [Daemon] (https://git-scm.com/book/en/v2/Git-on-the-Server-Git-Daemon) Access:**

The git daemon running on gitbox allows access to the repository using the git:// protocol.

*Note: This example assumes you are running gitbox using the default docker mappings defined above. If not, adjust accordingly.*

From your docker client cli:

    git clone git://<docker host ip or hostname>/myrepo.git
    
**Git [SMART-HTTP] (https://git-scm.com/book/en/v2/Git-on-the-Server-Smart-HTTP) Access:**

The git smart-http service running on gitbox allows a more traditional approach to accessing your repositories. This is similar to what most use with hosted repositories such as github.

From your docker client cli:

    git clone http://<docker host ip or hostname>/git/myrepo.git
    
*Note: There is a slightly differnt url used in retrieving the git repository in this method. This is in contrast to the git:// protocol used by git-daemon. This process will require authentication to the http server on clone, pull, or push. See Authentication.*

**Authentication:**

The authentication method and interaction with git and gitlist is still a work in progress. This would *not* be considered a secure system at this point. That being said, some authentication is in place through manual modifications to the nginx htpasswd file. This authentication only applies to read and write access via the git smart-http protocol. The gitlist webinterface is unsecured but can be switch to require authentication via the nginx.conf file if needed. 

*Note: Git-daemon is read-only regardless of this setup.*

To clear the default passwords and define a new one run the following from your docker host:

    docker exec gitbox htpasswd -cb /etc/nginx/htpasswd <user> <pass>
    
To add additional credentials to the currently defined ones, run the following from your docker host:

    docker exec gitbox htpasswd -b /etc/nginx/htpasswd <user> <pass>
    
News:
-----

*Change log 2015-7-28*

* Changed git-daemon to run with only read only repo access
* Added 'export' option to repoadd.sh and repoclone.sh scripts
* Modified README.md to reflect updates

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
* Add unauthenticated options for git clone over smart-http (currently both read and write is authenticated).

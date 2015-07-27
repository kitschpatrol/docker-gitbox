GITBOX
======

*work in progress...*

GIT offers a [variety of protocols] (https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) to access a repository. This docker image is configured with the following access methods.

* git daemon
* git smart http (nginx)
* gitlist web (nginx)

*Default Username and password for authentication have been set to gitadmin gitsecret. See notes below about changing credentials.*

**To run from hub.docker.com image repo:**

    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v /my/git/repo/directory:/repos nmarus/gitbox
    
**To run from github repo:**

    git clone -b stable https://github.com/nmarus/docker-gitbox.git
    cd docker-gitbox
    docker build --rm=true -t nmarus/gitbox .
    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v /my/git/repo/directory:/repos nmarus/gitbox

Server Repo Setup:
------------------

**Setup a empty repository from docker host:**

    docker exec gitbox repoadd.sh <reponame>.git <description>
    
*example:*
    
    docker exec gitbox repoadd.sh myrepo.git "This is my first git repo."
    
**Clone an existing repo from another location:**

    docker exec gitbox repoclone.sh <url>
    
*example:*
    
    docker exec gitbox repoclone.sh https://github.com/nmarus/docker-gitbox.git

Client / Server Connection:
---------------------------

**Setup client to use empty repository**

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

Open internet browser to http://192.168.10.52 to access web repo browsing...

**Git [Daemon] (https://git-scm.com/book/en/v2/Git-on-the-Server-Git-Daemon) Access:**

    git clone git://192.168.10.52/myrepo.git
    
**Git HTTP Access:**

    git clone htp://192.168.10.52/git/myrepo.git
    
**Authentication:**

    #erase password file and create initial creds
    docker exec gitbox htpasswd -cb /etc/nginx/htpasswd <user> <pass>
    #add additional users
    docker exec gitbox htpasswd -b /etc/nginx/htpasswd <user> <pass>
    
News:
-----

*Change log 2015-7-27*

* Added repoclone option
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

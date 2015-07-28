GITBOX
======

*work in progress...*

GIT offers a [variety of protocols] (https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) to access a repository. This docker image is configured with the following access methods.

* git daemon (git://[...])
* git smart-http (powered by nginx)
* gitlist web (powered by nginx)

*Note: Default Username and password for authentication have been set to gitadmin:gitsecret. See notes below about changing credentials. It is advised you reset the default credentails immediatly after installation.*

**To run from hub.docker.com image repository:**

From your docker host:

    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v /my/git/repo/directory:/repos nmarus/gitbox
    
**To run from github repository (Method 1):**

From your docker host:

    git clone -b stable https://github.com/nmarus/docker-gitbox.git
    cd docker-gitbox
    docker build --rm=true -t nmarus/gitbox .
    docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v </my/git/repo/directory>:/repos nmarus/gitbox


Server Repository Setup and Admin:
----------------------------------
After installing gitbox, the first thing you will want to do is add some repositories. This can eitehr be an empty repository, or an existing repository from another git server or [github.com.] (https://github.com)

To make this setup easier, gitbox allows an administrator to define these directly from the docker host without needing to access the shell of the containr, or have to worry about setting proper permissions on the files in the docker host's mapped volume. 

**To setup an empty repository:**

    docker exec gitbox repoadd.sh <reponame>.git <description> [export]
    
*example:*
    
    docker exec gitbox repoadd.sh myrepo.git "This is my first git repo." export
    
*Note: Adding the option 'export' keyword to this command marks the repository exportable for read-only access from git-daemon (git://[...]). If 'export' is not specified, then the repository must be authenticated to via git smart-http. 
    
**To clone an existing repository from another location:**

    docker exec gitbox repoclone.sh <url> [export]
    
*example:*
    
    docker exec gitbox repoclone.sh https://github.com/nmarus/docker-gitbox.git export
    
*Note: Adding the option 'export' keyword to this command marks the repository exportable for read-only access from git-daemon (git://[...]). If 'export' is not specified, then the repository must be authenticated to via git smart-http. 
    
**To delete a gitbox repository:**

    docker exec gitbox repodelete.sh <reponame>.git //use with caution//
    
*example:*
    
    docker exec gitbox repodelete.sh docker-gitbox.git

Client / Server Connection:
---------------------------

**Setup client to use empty repository via http**

*Note: This example assumes you have created a empty repository (as show above) named "myrepo.git". This is intended to be executed from your git client command line inside the directory you wish to store the repository locally. See [Getting Started - Git Basics.] (https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)*

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
    
**Setup client to clone a repository via git-daemon***

    git clone git://<docker host ip or hostname>/myrepo.git
    
*Note: This assumes the 'export' keyword was used when creating this repository. 
    
**Setup client to clone a repository via git smart-http***

    git clone http://<docker host ip or hostname>/git/myrepo.git
    
*Note: Notice the URL difference between this method and the previous. This process will require authentication to the http server on clone, pull, or push. See Authentication.*

**[Gitlist] (http://gitlist.org/) Browser Access:**

You can access git box using a internet browser. This utilizes the gitlist project. 

*Note: This example assumes you are running gitbox using the default docker mappings defined above. If not, adjust accordingly.*

Open an internet browser to to the dockerbox gitbox is running on to access the gitlist interface and browse the repositories on gitbox.

    http://<docker host ip or hostname>

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

The authentication method and interaction with git and gitlist is still a work in progress. This would *not* be considered a secure system at this point. That being said, some authentication is in place through modification to the nginx htpasswd file. This authentication only applies to read and write access via the git smart-http protocol. Git-daemon is readonly regardless of this setup.

*Clear (-c) password file and create (-b) initial creds*

    docker exec gitbox htpasswd -cb /etc/nginx/htpasswd <user> <pass>
    
*Add (-b) additional users to existing password file*

    docker exec gitbox htpasswd -b /etc/nginx/htpasswd <user> <pass>
    
News:
-----

*Change log 2015-7-27*

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

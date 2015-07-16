#!/bin/bash
git stash
git clean -f
git pull
docker stop gitbox
docker rm gitbox
docker build --rm=true -t nmarus/gitbox .
docker run -d -it --name gitbox -p 80:80 -p 9418:9418 -v /srv/repos:/repos nmarus/gitbox
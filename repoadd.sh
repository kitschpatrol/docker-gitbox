#!/bin/bash

HELP_TEXT="useage: $0 <reponame.git> '<repo description>'"

#Permissions
USER=git
GROUP=git

#Reopository Path
REPO=/repos/

#GIT executable
GIT=`which git`

#Args
NAME=$1
DESC=$2

if [ $# != "2" ]; then
  echo $HELP_TEXT
  exit 1
fi

if [[ $NAME =~ \.git$ ]]; then
  $GIT init --bare --shared $REPO$NAME
  echo $DESC > $REPO$NAME/description
  touch $REPO$NAME/git-daemon-export-ok
  chown $USER:$GROUP -R $REPO
else
  echo $HELP_TEXT
  exit 1
fi

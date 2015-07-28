#!/bin/bash

HELP_TEXT="useage: $0 <reponame.git> '<repo description>' [export]"

#Permissions
USER="git"
GROUP="git"

#Reopository Path
REPO="/repos"

#GIT executable
GIT="`which git`"

if [ $# == "0" ]; then
  echo $HELP_TEXT
  exit 1
fi

#Args
NAME=$1
DESC=$2

if [[ $NAME =~ \.git$ ]]; then
  $GIT init --bare --shared $REPO/$NAME
  echo $DESC > $REPO/$NAME/description
  if [ "$3" == "export" ]; then touch $REPO/$NAME/git-daemon-export-ok; fi
  chown $USER:$GROUP -R $REPO
else
  echo $HELP_TEXT
  exit 1
fi

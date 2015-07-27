#!/bin/bash

HELP_TEXT="usage: $0 <reponame.git> //use with caution//"

#Permissions
USER="git"
GROUP="git"

#Reopository Path
REPO="/repos"

#GIT executable
GIT="`which git`"

#Args
NAME=$1

if [ $# != "1" ]; then
  echo $HELP_TEXT
  exit 1
fi

if [[ $NAME =~ \.git$ ]]; then
  rm -rf $REPO/$NAME
else
  echo $HELP_TEXT
  exit 1
fi

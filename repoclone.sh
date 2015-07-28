#!/bin/bash

HELP_TEXT="usage: $0 <repo url> [export]"

#Permissions
USER=git
GROUP=git

#Reopository Path
REPO="/repos"

#GIT executable
GIT="`which git`"

#Args
URL=$1
NAME="$(echo "$(echo "$URL" | grep / | cut -d/ -f $(($(grep -o '/' <<< "$URL" | wc -l)+1)) -)")"

if (( $# > 2 )); then
  echo $HELP_TEXT
  exit 1
fi

if [[ $NAME =~ \.git$ ]]; then
  $GIT clone --bare --shared $URL $REPO/$NAME/
  echo "Cloned from ${URL}" > $REPO/$NAME/description
  if [ "$2" == "export" ]; then touch $REPO/$NAME/git-daemon-export-ok; fi
  chown $USER:$GROUP -R $REPO
else
  echo $HELP_TEXT
  exit 1
fi

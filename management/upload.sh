#!/bin/bash

##########################################################################
# Upload to the remote server all the website files that have been changed
# since the last upload.
# 
# NOTE: file deleted are not handled, you have to manually remove them 
# from the repository.
#
# Author: Generoso Pagano
##########################################################################

# Configuration

# you may want to change this
REMOTE=pagano@intra-id:/www-id/Pages_Perso_Mescal/generoso.pagano

# you should not change this
CONTENT_DIR="project"
LAST_SHA1_FILE="management/LASTSHA"

function rebase() {
  NEW_SHA1=`git rev-parse HEAD`
  echo "Rebasing the last sha1 to current HEAD ("$NEW_SHA1")"
  echo $NEW_SHA1 > $LAST_SHA1_FILE
}

# Body

LAST_SHA1=`cat ${LAST_SHA1_FILE}`
if [ $? != 0 ] ; then
  echo "Warning: ${LAST_SHA1_FILE} file not found."
  rebase
  echo "Automatically created with current HEAD as last uploaded commit."
  exit
fi

if [ $# -gt 0 ] && [ $1 == "--rebase" ]; then
  rebase
  exit
fi

echo "Uploading all files changed from commit $LAST_SHA1"

FILES=`git diff --diff-filter=ACMRTUXB --name-only HEAD ${LAST_SHA1} | grep -v .settings | grep -v .project | grep ${CONTENT_DIR}`

if [ -z "$FILES" ]; then
  echo "No file to upload"
  exit
fi

echo "Files to upload: " $FILES

scp $FILES $REMOTE

if [ $? == 0 ] ; then
  echo "Files successfully uploaded to $REMOTE"
  NEW_SHA1=`git rev-parse HEAD`
  echo $NEW_SHA1 > $LAST_SHA1_FILE
fi



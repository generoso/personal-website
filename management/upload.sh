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
MANAGEMENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="${MANAGEMENT_DIR}/.."
PROJECT_DIR="${REPO_DIR}/project"
LAST_SHA1_FILE="${MANAGEMENT_DIR}/LASTSHA"

###################################################################
# In the functions below we work under the hypothesis that all used
# paths are either absolute or relative to the repo dir.
###################################################################

# Write the current HEAD in the LAST SHA1 file
function rebase() {
    NEW_SHA1=`git rev-parse HEAD`
    echo "Rebasing the last sha1 to current HEAD ("$NEW_SHA1")"
    echo $NEW_SHA1 > $LAST_SHA1_FILE
}

# main function
function main() {
    
    LAST_SHA1=`cat ${LAST_SHA1_FILE}`

    # last sha1 file not present
    if [ $? != 0 ] ; then
	echo "Warning: ${LAST_SHA1_FILE} file not found."
	rebase
	echo "Automatically created with current HEAD as last uploaded commit."
	return
    fi

    # explicit rebase 
    if [ $# -gt 0 ] && [ $1 == "--rebase" ]; then
	rebase
	return
    fi

    # dry ryn
    DRY=0
    if [ $# -gt 0 ] && [ $1 == "--dry" ]; then
	DRY=1
    fi

    # normal operations: last sha1 found
    echo "Uploading all files changed from commit $LAST_SHA1"
    FILES=`git diff --diff-filter=ACMRTUXB --name-only HEAD ${LAST_SHA1} | grep -v .settings | grep -v .project | grep ${PROJECT_DIR}`
    if [ -z "$FILES" ]; then
	echo "No file to upload"
	return
    fi
    echo "Files to upload: " $FILES
    if [ $DRY -eq 0 ]; then
	scp $FILES $REMOTE
	if [ $? == 0 ] ; then
	    echo "Files successfully uploaded to $REMOTE"
	    rebase
	fi
    else 
	echo "Dry run. No file actually uploaded"
    fi


}

###############

OLD_DIR=`pwd`
cd "${REPO_DIR}"

main $@

cd "${OLD_DIR}"

##############

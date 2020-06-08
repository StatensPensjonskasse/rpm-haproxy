#!/bin/bash

REPOID='luarepo'
REPONAME='Lua repsitory'
BASEURL=
FORCE=
QUIET=

function Usage {
    local rc=${1:-}

    echo "SYNOPSIS"
    echo "    $(basename "$0") [-hfq] [-b BASEURL]"

    exit "$rc"
}

while getopts b:fp:qi:l: OPT ; do
    case "$OPT" in
        b)
            BASEURL=$OPTARG;;
        f)
            FORCE='true';;
        q)
            QUIET='true';;
        h)
            Usage 0;;
        ?)
            Usage 1;;
    esac
done
shift $((OPTIND - 1))

if [[ -z "$BASEURL" ]] ; then
    read -p 'Enter Lua repository base url (-b): ' BASEURL
fi

REPOFILE="/etc/yum.repos.d/$REPOID.repo"
if [[ -e $REPOFILE ]] ; then
    if [[ "$FORCE" == 'true' ]] ; then
        sudo rm -f $REPOFILE
    else
        echo "ERROR: Repo definition '$REPOFILE' already exists"
        exit 1
    fi
fi

sudo touch $REPOFILE
echo "[$REPOID]" | sudo tee -a $REPOFILE > /dev/null
echo "name=$REPONAME" | sudo tee -a $REPOFILE > /dev/null
echo "baseurl=$BASEURL" | sudo tee -a $REPOFILE > /dev/null
echo "enabled=1" | sudo tee -a $REPOFILE > /dev/null
echo "gpgcheck=0" | sudo tee -a $REPOFILE > /dev/null
sudo yum clean expire-cache > /dev/null

[[ -z "$QUIET" ]] && echo "Created '$REPOFILE'"

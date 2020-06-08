#!/bin/bash
#set -x

LUA_OPTS=
EXTRA_OBJS=
FORCE=
QUIET=

function Usage {
    local rc=${1:-}

    echo "SYNOPSIS"
    echo "    $(basename "$0") [-hfq] [-l LUA_OPTS] [-o EXTRA_OBJS]"

    exit "$rc"
}

while getopts fqhl:o: OPT ; do
    case "$OPT" in
        f)
            FORCE='true';;
        q)
            QUIET='true';;
        h)
            Usage 0;;
        l)
            LUA_OPTS=$OPTARG;;
        o)
            EXTRA_OBJS=$OPTARG;;
        ?)
            Usage 1;;
    esac
done
shift $((OPTIND - 1))

if [[ -z "$LUA_OPTS" ]] ; then
    read -p 'Use lua? (y/n): ' USE_LUA
    LUA_OPTS='USE_LUA=1'
fi
if [[ ! "$LUA_OPTS" =~ USE_LUA ]] ; then
    read -p 'Use lua? (y/n): ' USE_LUA
    LUA_OPTS="USE_LUA=1 ${LUA_OPTS}"
fi
if [[ "$LUA_OPTS" =~ USE_LUA=1 ]] ; then
    if [[ ! "$LUA_OPTS" =~ LUA_PACKAGE ]] ; then
        read -p 'Enter Lua package name: ' PACKAGENAME
        LUA_OPTS="${LUA_OPTS} LUA_PACKAGE=${PACKAGENAME}"
    fi
    if [[ ! "$LUA_OPTS" =~ LUA_INC ]] ; then
        read -p 'Enter Lua include directory: ' INCDIR
        LUA_OPTS="${LUA_OPTS} LUA_INC=${INCDIR}"
    fi
    if [[ ! "$LUA_OPTS" =~ LUA_LIB ]] ; then
        read -p 'Enter Lua library directory: ' LIBDIR
        LUA_OPTS="${LUA_OPTS} LUA_LIB=${LIBDIR}"
    fi
fi

if [[ -z "$EXTRA_OBJS" ]] ; then
    read -p 'Enter Extra object files to include (-o): ' EXTRA_OBJS
fi

SETENVFILE="./setEnv"
if [[ -e $SETENVFILE ]] ; then
    if [[ "$FORCE" == 'true' ]] ; then
        rm -f $SETENVFILE
    else
        echo "ERROR: '$SETENVFILE' already exists"
        exit 1
    fi
fi

touch $SETENVFILE
for lua_opt in $LUA_OPTS ; do
    echo "export $lua_opt" >> $SETENVFILE
done
echo "export EXTRA_OBJS=\"$EXTRA_OBJS\"" >> $SETENVFILE

[[ -z "$QUIET" ]] && echo "Created '$SETENVFILE'"
[[ -z "$QUIET" ]] && echo "Use 'source setEnv' to prepare build shell"

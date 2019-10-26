#!/bin/bash

# ./vars

VAR_FILE=$2
if [ -z "$VAR_FILE" ]; then
    VAR_FILE='./vars'
fi

dump_envvars() {

    if [ -f "$VAR_FILE" ]; then
        cat $VAR_FILE
    fi

    compgen -v | while read -r VARNAME; do
        PREFIX="${VARNAME:0:4}"
        if [ "$PREFIX" == "ARG_" ] ; then
            echo "${VARNAME:4}=${!VARNAME}"
        fi
    done
}

tmpl() {
    local FILENAME
    local CONTENT
    local VARS
    local EXP
    
    FILENAME=$1
    CONTENT=`cat $FILENAME`

    VARS=`dump_envvars`

    for VAR in $VARS; do
        KEY="${VAR%%=*}"
        VALUE="${VAR##*=}"
        EXP="\\\$\\\$$KEY"
        CONTENT=`echo "$CONTENT" | sed "s~$EXP~$VALUE~g"`
    done

    echo "$CONTENT"
}


FILE=$1
if ! [ -z "$FILE" ] ; then
    tmpl $FILE
fi


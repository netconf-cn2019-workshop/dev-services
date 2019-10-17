#!/bin/bash

# ./vars

VAR_FILE=$2
if [ -z "$VAR_FILE" ]; then
    VAR_FILE='./vars'
fi

tmpl() {
    local FILENAME
    local CONTENT
    local VARS
    local EXP
    
    FILENAME=$1
    CONTENT=`cat $FILENAME`
    VARS=`cat $VAR_FILE`

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


#!/bin/env bash

get-label() {
    grep ';LBL \[' $1 | awk '{print $1,$3}' | sort | uniq | sed -s 's/\[//g;s/\]//g'
}

make-sed() {
    while read -r lnum label
    do
        echo "s/\(\[$label\]\)/$lnum\t;\1/g"
    done
}

sed-list() {
    sed -f /dev/stdin $1
}

pre-process() {
    echo "s/^\s\+;.*//g"
    echo "/^\s*$/d"
    echo "/^\s*;.*$/d"
    echo "s/^\(.*\s\+\)LBL/\1;LBL/g"
}

add-lnum() {
    while IFS= read line
    do
        i=$((i+1))
        printf 'M%03d %s\n' "$i" "$line" 
        if [[ $i -gt 1 && "$line" =~ [:alpha:]*[:digit:]*[:space:]*\;LBL ]]; then
            i=$((i-1))
        fi
    done
}

file-withnum() {
    pre-process | sed-list $1 | add-lnum
}

get-label <(file-withnum $1) | make-sed | sed-list <(file-withnum $1) 

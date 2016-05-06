#!/bin/env bash

get-label() {
    grep 'LBL \[' $1 | awk '{print $3}' | sort | uniq | sed -s 's/\[//g;s/\]//g'
}

make-sed() {
    local ivar=16
    local jvar=17
    local i
    echo "s/\s(I)/ IND $ivar/g"
    echo "s/\s(J)/ IND $jvar/g"
    echo "s/\<I\>/$ivar/g"
    echo "s/\<J\>/$jvar/g"
    while read line
    do
        i=$((i+1))
        ich=$( printf '%02d' $i )
        echo "s/\(\[$line\]\)/$ich\t;\1/g"
    done
}

sed-list() {
    sed -f /dev/stdin $1
}

pre-process() {
    echo "s/^\s\+;.*//g"
    echo "/^\s*$/d"
    echo "/^\s*;.*$/d"
}

add-lnum() {
    while IFS= read line
    do
        i=$((i+1))
        printf '%03d %s\n' "$i" "$line" 
    done
}

file-withnum() {
    pre-process | sed-list $1 | add-lnum
}

get-label <(file-withnum $1) | make-sed | sed-list <(file-withnum $1) > $1.txt
perl txt2raw.pl $1.txt

#!/bin/env bash

get-label() {
    grep 'LBL \[' $1 | awk '{print $3}' | sort | uniq | sed -s 's/\[//g;s/\]//g'
}

make-sed42() {
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

add-lnum42() {
    while IFS= read line
    do
        i=$((i+1))
        printf '%03d %s\n' "$i" "$line" 
        #if i>1
    done
}

file-withnum42() {
    pre-process | sed-list $1 | add-lnum42
}

get-label <(file-withnum42 $1) | make-sed42 | sed-list <(file-withnum42 $1) > $1.txt
perl txt2raw.pl $1.txt

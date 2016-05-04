#!/bin/env bash

get-label() {
    grep 'LBL \[' $1 | awk '{print $2}' | sort | uniq | sed -s 's/\[//g;s/\]//g'
}

make-sed() {
    local ivar=16
    local jvar=17
    local i
    echo "s/^\s\+;.*//g"
    echo "s/\s(I)/ IND $ivar/g"
    echo "s/\s(J)/ IND $jvar/g"
    echo "s/\<I\>/$ivar/g"
    echo "s/\<J\>/$jvar/g"
    while read line
    do
        i=$((i+1))
        echo "s/\(\[$line\]\)/$i\t;\1/g"
    done
}

show-list() {
    sed -f /dev/stdin $1
}

get-label $1 | make-sed | show-list $1 > $1.txt
perl txt2raw.pl $1.txt

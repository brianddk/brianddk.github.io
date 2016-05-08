#!/bin/env bash

alias rebuild='source ./build.sh ../mancala.asm'

keep="#35s"
asm=$1
lst=${1%.asm}.lst
txt=${1%.asm}.txt
raw=${1%.asm}.raw

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
    echo "s/$keep/    /g"
    echo "s/^\s\+;.*//g"
    echo "/^#.*$/d"
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

mklstxt() {
    tee $1 | sed 's/\s\+;.*//g; s/\s\+/ /g' > $2
}

get-label <(file-withnum $asm) | make-sed | sed-list <(file-withnum $asm) | mklstxt $lst $txt

mv $txt $(basename $txt)
mv $lst $(basename $lst)

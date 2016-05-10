#!/bin/env bash

alias rebuild='source ./build.sh ../mancala.asm'

keep="#42s"
asm=$1
lst=${1%.asm}.lst
txt=${1%.asm}.txt
raw=${1%.asm}.raw
braw=$(basename $raw)
btxt=$(basename $txt)
blst=$(basename $lst)
rlst=../rel/${blst%.lst}-42s.lst
rtxt=../rel/${btxt%.txt}-42s.txt
rraw=../rel/${braw%.raw}-42s.raw

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
    echo "s/$keep/    /g"
    echo "s/^\s\+;.*//g"
    echo "/^#.*$/d"
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
    pre-process | sed-list $asm | add-lnum
}

mklstxt() {
    tee $1 | sed 's/\s\+;.*//g; s/\s\+/ /g' > $2
}

get-label <(file-withnum $asm) | make-sed | sed-list <(file-withnum $asm) | mklstxt $lst $txt
perl ../txt2raw.pl $txt

mv $txt.raw $braw
mv $txt $btxt
mv $lst $blst

cp $braw $rraw
cp $btxt $rtxt
cp $blst $rlst

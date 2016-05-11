#!/bin/env bash

alias rebuild='source ./build.sh ../mancala.asm'

keep="#41c"
asm=$1
lst=${1%.asm}.lst
txt=${1%.asm}.txt
raw=${1%.asm}.raw
log=${1%.asm}.log
braw=$(basename $raw)
btxt=$(basename $txt)
blst=$(basename $lst)
blog=$(basename $log)
rlst=../rel/${blst%.lst}-41cx.lst
rtxt=../rel/${btxt%.txt}-41cx.txt
rraw=../rel/${braw%.raw}-41cx.raw

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
    echo "s/\<x\>/\*/g"
    echo "s/\<Rv\>/RDN/g"
    echo "s/\<IP\>/INT/g"
    echo "s/\<STO+/ST+/g"
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

dosbox="$(cygpath -u "$(cmd /c "<NUL set /p=%programfiles(x86)%\DOSBox-0.74\DOSBox.exe")")"
dbconf="$LOCALAPPDATA/DOSBox/dosbox-0.74.conf"
hp41conf="/tmp/41c.conf"
tmpdir="$(cygpath -w /tmp)"
rawout="$(cygpath -w $(cd $(dirname $raw); pwd))"
hp41uc="$(cygpath -w $APPDATA/hp41uc)"
cp "$dbconf" "$hp41conf"

cat << EOF >> "$hp41conf"
    mount p: $rawout
    mount h: $hp41uc
    mount t: $tmpdir
    h:\HP41UC.EXE /t=p:\\$btxt /r=p:\\$braw /g /n > t:\\$blog
    exit
EOF

dbconf="$(cygpath -w $hp41conf)"
"$dosbox" -conf "$dbconf"

mv ${raw^^} $braw
mv $txt $btxt
mv $lst $blst


cp $braw $rraw
cp $btxt $rtxt
cp $blst $rlst

cat /tmp/${blog^^}

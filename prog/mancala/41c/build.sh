#!/bin/env bash

alias rebuild='source ./build.sh ../mancala.asm'

keep="#41c"
asm=$1
lst=${1%.asm}.lst
txt=${1%.asm}.txt
raw=${1%.asm}.raw

dosbox="${PROGRAMFILES}/DOSBox-0.74/DOSBox.exe"
dbconf="$LOCALAPPDATA/DOSBox/dosbox-0.74.conf"
hp41conf="/tmp/41c.conf"
rawout="$(cygpath -w $(cd $(dirname $raw); pwd))"
hp41uc="$(cygpath -w $APPDATA/hp41uc)"
cp "$dbconf" "$hp41conf"
#dos2unix "$hp41conf"

cat << EOF >> "$hp41conf"
    mount p: $rawout
    mount h: $hp41uc
    h:\HP41UC.EXE > p:\mancala.raw
    exit
EOF


dbconf="$(cygpath -w $hp41conf)"
"$dosbox" -conf "$dbconf"

mv ${raw^^} $(basename $raw)

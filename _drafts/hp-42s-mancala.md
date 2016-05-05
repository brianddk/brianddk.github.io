---
layout: post
title:  "hp35s Software"
#date:   2016-05-04 17:20 -0500
categories: calc hp42s hp35s
---
This is a mancala program I wrote for the hp42s (Free42).  For those not familiar with mancala, its a very achient game that has become repopularized over the last few years in the US.  You can now get a mancala board at most stores that sell board games.  This particular 'flavor' of mancala kahla(6,4), but it seemed to be the one that is most available in my area.  This is a fun game to play, but most mathmatical analysis of possible permutations make this game signifigantly harder for Player 2.  Whoever goes first is likely to win.

Download [`mancala.raw`](https://github.com/brianddk/brianddk.github.io/blob/master/prog/mancala/mancala.raw?raw=true)

### HP 35s Portable
I had originally planned on writting this for the hp35s.  I still intend to port it, so I wrote this, basically, in hp35s syntax.  The primary listing is in an '.asm' file that I put through a very gentle pre-processor.  This is done to keep all the `LBL`, `XEQ`, `GTO` statements synced up since the 35s and 42s handle them different.  I also prefer verbose label names, but that has a tendency of poluting your program catalog with all your 'subroutines'.  The pre-processor will take marked-up verbose labels and convert them to 42s local-labels or 35s line-labels.  Neither of which will pollute the catalog.  I have also choosen to use no named variables for similar reasons.  Since I plan to port this to the 35s, I choose to only access registers indirectly.  This is the only way that the 35s can access un-named registers, so enforcing this makes the porting a breeze.  References to `I`, `(I)`, `J`, and `(J)`, are all 35s notation.

### Build Process
The build command does the pre-processing with `sed`.  Once this is done, it feeds the result through txt2raw.pl (by Vini Matangrano).  This will both check for syntax errors and produce an hp41s raw-file.  My only hp41s is the one simulated through Free42, so no promesses, though I'm not really doing anything special here to cause concern.

### Registers
Since a real mancala board uses a counter-clockwise rotation in play, I have configured the phisical registers in a similar fashion.  This does make gameplay more natural for Player 1 than Player 2.

```asm
; R00       - P2 'Home' pit
; R01       - P1 pit #1
; R02       - P1 pit #2
; R03       - P1 pit #3
; R04       - P1 pit #4
; R05       - P1 pit #5
; R06       - P1 pit #6
; R07       - P1 'Home' pit
; R08       - P2 pit #6
; R09       - P2 pit #5
; R10       - P2 pit #4
; R11       - P2 pit #3
; R12       - P2 pit #2
; R13       - P2 pit #1
; R14       - P1 Display Vector
; R15       - P2 Display Vector
; R16       - Virtual 'I' register
; R17       - Vertual 'J' register
```

### Flags
The flags used are fairly self explanitory.  Originally, in the 35s design, I had intended on using the flag indicator as the way for Player 1 and Player 2 to know who's turn it was.  Since the 42s doesn't have a flag indicator, I had to use `GRAD` and `RAD` to make that distinction.

```asm
; FLAG1     - Player 1 turn flag
; FLAG2     - Player 2 turn flag
; FLAG3     - Winner found flag
; FLAG4     - Bad 'pick' choice flag
```

### Game Display
The game display will show a number between 1-million and 2-million, for both Player 1 and Player 2.  The fractional part is the player's score (0.10 = 10 points).  The number in the million'th place is purely for alignment and should be ignored, the other numbers represent your 6 'pits'.  The 'pit' to the far left is 'pit 1' the pit to the far right is 'pit 6'.  To move, you specify a pit number to move.

```asm
; Game Display
;
; x: Z,DCB,A98.P2
; y: Z,123,456.P1
;
; Where,
;   'Z,'    - Ignore the 'millionth' place, its a place holder, nothing more
;   'P1'    - The score for Player 1 (in the X vector)
;   'P2'    - The score for Player 2 (in the Y vector)
;   '1|D'   - # of beans in 'pit #1' for P1 and P2
;   '2|C'   - # of beans in 'pit #2' for P1 and P2
;   '3|B'   - # of beans in 'pit #3' for P1 and P2
;   '4|A'   - # of beans in 'pit #4' for P1 and P2
;   '5|9'   - # of beans in 'pit #5' for P1 and P2
;   '6|8'   - # of beans in 'pit #6' for P1 and P2
;
; Indicators
;   'GRAD'  - Player1's turn when 'GRAD' is displayed
;   'RAD'   - Player2's turn when 'RAD' is displayed
```

### Gameplay
To start the game, simply `XEQ` the `MANCA` program.  The game will show the initial board and set the indicator for Player 1 to take his turn.  Player 1 can then study the board and pick a pit to move.  Thier pick is given by placing the pick in the level 1 (x) on the stack then hit `run` (aka `R/S`).  The game will then move the beans according to the rules and redisplay the board.  It is now time for the next move.  The `GRAD` / `RAD` indicator will light to instruct the players as to whos turn it is.  Keep in mind, earning extra turns is a key strategy of the game.

### Bugs
I have a few features that I haven't implented yet, aka 'Bugs'

1. Display is base 10, so more than 9 beans in a pit is a problem - For the 35s, I will simply make a modified version of this display in `HEX`.  This will allow 15 beans in a pit, which by most game permutations is unlikely.  For the 42s, I will have to do some `XTOA` commands.  This is simple enough, but just a hunk of code I haven't written yet.
2. When a player empties all thier pits, the game should end, but doesn't - This is another simple fix, but something I just haven't done yet.

### Listings
Here are the listings, but do recall that you will likely need to understand that pre-processors are the key here.

[`mancala.asm`](https://github.com/brianddk/brianddk.github.io/blob/master/prog/mancala/mancala.asm)

```asm
 "MANCA"
    ;Main Mancala program
        XEQ [INIT]                      ; Init the game registers
        LBL [MAIN]                      ; Main game loop
            XEQ [CHECK-WINNER]          ; Check for a winner
            FS? 3                       ; Flag3 = Winner Found!
                GTO [DONE]              ; Finished when a winner is found
            LBL [REDISPLAY]             ; Come here if we pick bad
            XEQ [DISPLAY]               ; Display the game board
            XEQ [PICK]                  ; Pick a move
            FS? 4                       ; Invalid move?
                GTO [REDISPLAY]         ; .. Redisplay
            XEQ [MOVE]                  ; Move the beans
            XEQ [SWITCH]                ; Swithch players
        GTO [MAIN]                      ; Loop for next move
        LBL [DONE]                      ; This is where we finish
        XEQ [CLEANUP]                   ; Cleanup we are done
    RTN
    ;
    ; .Init registers
    LBL [INIT]                          ; Init the game registers
        CF 1                            ; Clear our flag regs
        CF 2
        CF 3
        CF 4
        13.0                            ; For i in 13..1
        STO I                           ; i
        4.0                             ; st-x = 4
        LBL [INIT-LOOP]
            STO (I)                     ; 4->(i)
            DSE I                       ; DSE i
        GTO [INIT-LOOP]
        0.0                             ; i now equals zero
        STO (I)                         ; 0->(i), i = 0
        7.0
        STO I
        X<>Y
        STO (I)                         ; 0->(i), i = 7
        SF 1                            ; P1'S Turn
        GRAD                            ; 42s Only, P1 indicator
    RTN
    ;
    ; Check for winner
    LBL [CHECK-WINNER]
        CF 3                            ; Clear winner found flag
        0
        STO J                           ; j
        7
        STO I                           ; i
        24.0
        RCL (I)                         ; (i)
        X>=Y?
            GTO [P1-WINNER]
        X<>Y
        RCL (J)                         ; (j)
        X>=Y?
            GTO [P2-WINNER]
        GTO [WINNER-RTN]
        LBL [P1-WINNER]
            "Player 1 won!"
            GTO [WINNER-DONE]
        LBL [P2-WINNER]
            "Player 2 won!"
        LBL [WINNER-DONE]
            SF 3                        ; Set winner found flag
            PROMPT
        LBL [WINNER-RTN]
    RTN
    ;
    ; Display the board
    LBL [DISPLAY]
        1.006
        STO I                           ; i
        14
        STO J                           ; "$(j)" == "$(14)"
        1000000.0
        STO (J)                         ; (j)=1,000,000
        LBL [P1-BOARD]
            ;STOP
            10.0                        ; WARN Base 10 for now
            6
            RCL I                       ; i
            IP
            -
            Y^X                         ; i^(6-ip(i))
            RCL (I)                     ; (i)
            x                           ; i^(6-ip(i)) * $(i)
            STO+ (J)                    ; @(j) += i^(6-ip(i)) + $(i)
            ISG I                       ; i
        GTO [P1-BOARD]
        15
        STO J                           ; j = P2-vector
        1000000.0
        STO (J)
        13.007
        STO I
        LBL [P2-BOARD]
            ;STOP
            10.0                        ; WARN Base 10 for now
            RCL I
            IP
            8
            -
            Y^X
            RCL (I)
            x
            STO+ (J)
            DSE I
        GTO [P2-BOARD]
        14
        STO I                           ; i = P1-vector
        ;                               ; 42s only code begin
        FIX 2
        RCL 7                           ; P1 SCORE
        100
        /
        STO+ (I)                        ; P1 VECTOR
        RCL 0
        100
        /
        STO+ (J)                        ; P2 VECTOR
        ;                               ; 42s only code end
        RCL (J)                         ; P2
        RCL (I)                         ; P1
        STOP
    RTN
    ;
    ; Pick a pit to move
    LBL [PICK]
        CF 4
        IP
        1
        X<>Y
        X<Y?
            SF 4
        6
        X<>Y
        X>Y?
            SF 4
        FS? 4
            GTO [PICK-DONE]
        STO I                           ; i=PICK
        FS? 1
            GTO [CHECK-PICK]
        14
        X<>Y
        -
        STO I                           ; i
        LBL [CHECK-PICK]
        RCL (I)                         ; (i)
        X=0?
            SF 4
        LBL [PICK-DONE]
        RCL I                           ; i
    RTN
    ;
    ; Move beans from selected pit
    LBL [MOVE]
        0
        X<> (I)                         ; (i)= 0 (MOVE BEANS OUT)
        STO J                           ; j=VALUE PREVIOUSLY IN (i)
        LBL [MOVE-LOOP]
            ; INCI SUBROUTINE-INLINE
            1.0
            RCL+ I                      ; i++ (MOVE REGISTER FORWARD)
            14.0
            MOD
            STO I                       ; i=(i+1)MOD(14)
            FS? 1                       ; P1?
                XEQ [SKIP0]             ; SKIP0 IF P1
            FS? 2
                XEQ [SKIP7]             ; SKIP7 IF P2
            ; INCI END-SUBROUTINE-INLINE
            1.0
            STO+ (I)                    ; (i)=(i)+1
            DSE J                       ; j--
        GTO [MOVE-LOOP]
        1.0
        RCL (I)
        X=Y?
            XEQ [WIN-BEANS]
    RTN
    ;
    ; SKIP0
    LBL [SKIP0]
        X=0?
            ISG I
        CF 0                            ; NOP
    RTN
    ;
    ; SKIP7
    LBL [SKIP7]
        7
        X<>Y
        X=Y?
            ISG I
        CF 0                            ; NOP
    RTN
    ;
    ; WIN-BEANS
    LBL [WIN-BEANS]
        ;STOP
        7
        RCL I
        FS? 1
            GTO [P1-WINBEANS]
        FS? 2
            GTO [P2-WINBEANS]
        RTN
        LBL [P1-WINBEANS]
            7.0
            STO J
            Rv
            X>=Y?
                RTN
            GTO [DONE-WINBEANS]
        LBL [P2-WINBEANS]
            0.0
            STO J
            Rv
            X<=Y?
                RTN
        LBL [DONE-WINBEANS]
        14.0
        X<>Y
        -
        STO I
        0
        X<> (I)
        STO+ (J)
    RTN
    ;
    ; Switch to other players turn
    LBL [SWITCH]
        7
        RCL I                           ; i contains the final register of move
        X=Y?                            ; if i=7, landed in a bank, free move
            RTN
        X=0?                            ; if i=0, landed in a bank, free move
            RTN
        FS? 1
        GTO [SWITCHTO-P2]
            CF 2
            SF 1
            GRAD
            GTO [SWITCH-DONE]
        LBL [SWITCHTO-P2]
            CF 1
            SF 2
            RAD
        LBL [SWITCH-DONE]
    RTN
    ;
    ; Clean up after game
    LBL [CLEANUP]
        CF 1
        CF 2
        CF 3
        CF 4
        FIX 4
        DEG
    RTN
END
```

[`build.sh`](https://github.com/brianddk/brianddk.github.io/blob/master/prog/mancala/build.sh)

```shell
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
    echo "/^\s*$/d"
    echo "/^\s*;.*$/d"
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
```

[`mancala.txt`](https://github.com/brianddk/brianddk.github.io/blob/master/prog/mancala/mancala.txt)

```
00 { 476-Byte Prgm }  40 CF 03            80 STO+ IND 17   120 X<>Y         160 GTO 11      200 14
01>LBL "MANCA"        41 0                81 ISG 16        121 X<Y?         161 1           201 X<>Y
02 XEQ 07             42 STO 17           82 GTO 12        122 SF 04        162 RCL IND 16  202 -
03>LBL 09             43 7                83 15            123 6            163 X=Y?        203 STO 16
04 XEQ 02             44 STO 16           84 STO 17        124 X<>Y         164 XEQ 26      204 0
05 FS? 03             45 24               85 1E6           125 X>Y?         165 RTN         205 X<> IND 16
06 GTO 05             46 RCL IND 16       86 STO IND 17    126 SF 04        166>LBL 21      206 STO+ IND 17
07>LBL 20             47 X>=Y?            87 13.007        127 FS? 04       167 X=0?        207 RTN
08 XEQ 04             48 GTO 14           88 STO 16        128 GTO 19       168 ISG 16      208>LBL 23
09 XEQ 18             49 X<>Y             89>LBL 15        129 STO 16       169 CF 00       209 7
10 FS? 04             50 RCL IND 17       90 10            130 FS? 01       170 RTN         210 RCL 16
11 GTO 20             51 X>=Y?            91 RCL 16        131 GTO 01       171>LBL 22      211 X=Y?
12 XEQ 10             52 GTO 17           92 IP            132 14           172 7           212 RTN
13 XEQ 23             53 GTO 28           93 8             133 X<>Y         173 X<>Y        213 X=0?
14 GTO 09             54>LBL 14           94 -             134 -            174 X=Y?        214 RTN
15>LBL 05             55 "Player 1 won!"  95 Y^X           135 STO 16       175 ISG 16      215 FS? 01
16 XEQ 03             56 GTO 27           96 RCL IND 16    136>LBL 01       176 CF 00       216 GTO 25
17 RTN                57>LBL 17           97 О             137 RCL IND 16   177 RTN         217 CF 02
18>LBL 07             58 "Player 2 won!"  98 STO+ IND 17   138 X=0?         178>LBL 26      218 SF 01
19 CF 01              59>LBL 27           99 DSE 16        139 SF 04        179 7           219 GRAD
20 CF 02              60 SF 03            100 GTO 15       140>LBL 19       180 RCL 16      220 GTO 24
21 CF 03              61 PROMPT           101 14           141 RCL 16       181 FS? 01      221>LBL 25
22 CF 04              62>LBL 28           102 STO 16       142 RTN          182 GTO 13      222 CF 01
23 13                 63 RTN              103 FIX 02       143>LBL 10       183 FS? 02      223 SF 02
24 STO 16             64>LBL 04           104 RCL 07       144 0            184 GTO 16      224 RAD
25 4                  65 1.006            105 100          145 X<> IND 16   185 RTN         225>LBL 24
26>LBL 08             66 STO 16           106 э            146 STO 17       186>LBL 13      226 RTN
27 STO IND 16         67 14               107 STO+ IND 16  147>LBL 11       187 7           227>LBL 03
28 DSE 16             68 STO 17           108 RCL 00       148 1            188 STO 17      228 CF 01
29 GTO 08             69 1E6              109 100          149 RCL+ 16      189 Rv          229 CF 02
30 0                  70 STO IND 17       110 э            150 14           190 X>=Y?       230 CF 03
31 STO IND 16         71>LBL 12           111 STO+ IND 17  151 MOD          191 RTN         231 CF 04
32 7                  72 10               112 RCL IND 17   152 STO 16       192 GTO 06      232 FIX 04
33 STO 16             73 6                113 RCL IND 16   153 FS? 01       193>LBL 16      233 DEG
34 X<>Y               74 RCL 16           114 STOP         154 XEQ 21       194 0           234 RTN
35 STO IND 16         75 IP               115 RTN          155 FS? 02       195 STO 17      235 END
36 SF 01              76 -                116>LBL 18       156 XEQ 22       196 Rv
37 GRAD               77 Y^X              117 CF 04        157 1            197 X<=Y?
38 RTN                78 RCL IND 16       118 IP           158 STO+ IND 16  198 RTN
39>LBL 02             79 О                119 1            159 DSE 17       199>LBL 06
```

Download [`mancala.raw`](https://github.com/brianddk/brianddk.github.io/blob/master/prog/mancala/mancala.raw?raw=true)

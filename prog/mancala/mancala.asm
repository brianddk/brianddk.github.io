; [rights]  Copyright Dan B. (brianddk) 2016 https://github.com/brianddk
; [license] Licensed under Apache 2.0 https://www.apache.org/licenses/LICENSE-2.0
; [repo]    https://github.com/brianddk/brianddk.github.io/blob/master/prog/mancala/mancala.asm
;
; Mancala game written for the hp 41s scientific calculator.
;
; Version: 0.1 (commit c790ba6 + 1)
;
; Rules: https://en.wikipedia.org/wiki/Kalah aka Kalah(6,4)
;
; Build:
;   txt2raw.pl  - by Vini Matangrano, a TXT to opcode compiler
;       http://thomasokken.com/free42/txt2raw/txt2raw.html
;   build.sh    - (by me) a bunch of `sed` to make LBL, XEQ, GTO, I, J easier.
;       https://github.com/brianddk/brianddk.github.io/blob/master/prog/mancala/build.sh
;
; Oddities:
;   This program is designed for the hp 35s which is why the notation is so very odd.
;   I decided to test in on Free42s since it would be easier to debug.  Porting back
;   to hp 35s should be fairly straight forward in this form.  I will eventually write
;   the offset calculator since the hp 35s has anonymous XEQ/GTO that I want to use.
;   I also went through great pains to not consume many program LBLs or variables.
;   That is why 'MANCA' is the only named label / variable.  In the 35s, the named
;   labels / variables will be prog 'M' and variables 'I', 'J'
;
; Bugs:
;   - Display is base 10, so more than 9 beans in a pit is a problem.
;   - When a player empties all thier pits the game is supposed to end... it doesn't.
;
; Layout
;
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
; FLAG1     - Player 1 turn flag
; FLAG2     - Player 2 turn flag
; FLAG3     - Winner found flag
; FLAG4     - Bad 'pick' choice flag
;
; Game board (to imagine)
;
; R00-R13 R12 R11-R10 R09 R08
;     R01 R02 R03-R04 R05 R06-R07
;
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

LBL "MANCA"
    ;Main Mancala program
        XEQ [INIT]                      ; Init the game registers
        LBL [MAIN]                      ; Main game loop
            XEQ [MKSCORE]               ; Display the game board
            XEQ [CHECK-WINNER]          ; Check for a winner
            FS? 3                       ; Flag3 = Winner Found!
                GTO [DONE]              ; Finished when a winner is found
            XEQ [PICK]                  ; Pick a move
            FS? 4                       ; Invalid move?
                GTO [MAIN]              ; .. try again
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
        13                              ; For i in 13..1
        STO I                           ; i
        4                               ; st-x = 4
        LBL [INIT-LOOP]
            STO (I)                     ; 4->(i)
            DSE I                       ; DSE i
        GTO [INIT-LOOP]
        0                               ; i now equals zero
        STO (I)                         ; 0->(i), i = 0
        7
        STO I
        X<>Y
        STO (I)                         ; 0->(i), i = 7
        SF 1                            ; P1'S Turn
        GRAD                            ; 42s Only, P1 indicator
    RTN
    ;                                   ; This routine will check for
    ; Check for winner                  ; .. the winner by looking at
    LBL [CHECK-WINNER]                  ; .. the 'home pits'
#35s    SF 10                           ; For 35s prompting
        CF 3                            ; Clear winner found flag
        0                               ; i = P1-home
        STO J                           ; j = P2-home
        7                               ; Compare P1-home to 24
        STO I                           ; .. if it is .gte. then won!
        RCL (I)                         ; p1-home,7,0
        25                              ; 25,p1h,7,0
        X<=Y?
            GTO [P1-WINNER]
        RCL (J)                         ; p2h,25,p1h,7
        X<>Y                            ; 25,p2h,p1h,7
        X<=Y?
            GTO [P2-WINNER]
        Rv
        X=Y?
            GTO [CHECK-TIE]
        GTO [WINNER-RTN]
        LBL [CHECK-TIE]
            R^
            1
            -
            X!=Y?
                GTO [WINNER-RTN]
            "TIE GAME"
            GTO [WINNER-DONE]
        GTO [WINNER-RTN]
        LBL [P1-WINNER]
            "PLAYER 1 WON"
            GTO [WINNER-DONE]
        LBL [P2-WINNER]
            "PLAYER 2 WON"
        LBL [WINNER-DONE]
            SF 3                        ; Set winner found flag
            XEQ [DISPLAY]
#41c        PROMPT                      ; The 42s uses prompt command
#42s        PROMPT                      ; The 42s uses prompt command
        LBL [WINNER-RTN]                ; .. But the 35s uses Flag 10
#35s    CF 10                           ; Restore (35s) default
    RTN
    ;
    ; Record the score
    LBL [MKSCORE]
        CF 3                            ; We use F3 for overflow
        CF 4                            ; We use F4 for a player2 indc.
        1.006
        STO I                           ; i
        14
        STO J                           ; "$(j)" == "$(14)"
        1000000
        STO (J)                         ; (j)=1,000,000
        LBL [P1-BOARD]                  ; 1m,14,1..
            XEQ [MKSCORE-COMMON]        ; Since we call twice, make a sub
            FS? 3
        GTO [P1-BOARD]
        SF 4                            ; Flag 4 means P2        
        15
        STO J                           ; j = P2-vector
        2000000
        STO (J)
        8.013                           ; Loop over R8..R13
        STO I                           ; I will be loop counter
        LBL [P2-BOARD]
            XEQ [MKSCORE-COMMON]        ; Since we call twice, make a sub
            FS? 3
        GTO [P2-BOARD]
        7                               ; Now we get the score and tack
        STO I                           ;.. it to the end of the number
        0                               ;.. as the FP
        STO J                           ; i = p1-home, j=p2-home
        0.01                            ; .01,0,7
        RCL (J)                         ; R0,.01,0,7
        x                               ; R0%,0,7,7
        0.01                            ; .01,R0%,0,7
        RCL (I)                         ; R7,.01,R0%,0
        x                               ; R7%,R0%,0,0
        14                              ; .. st-y = p2-score/100
        STO I
        15
        STO J                           ; i = p1 vector, j=p2-vector
        Rv                              ; st-x = p1-score/100
        Rv                              ; .. st-y = p2-score/100
        STO+ (I)
        X<>Y
        STO+ (J)
        CF 3                            ; Clear the flags
        CF 4                            ; .. we don't need anymore
        FIX 2
    RTN
    ;
    ;MKSCORE-COMMON
    LBL [MKSCORE-COMMON]
        ;STOP
        CF 3
        10.0                        ; WARN Base 10 for now
        FS? 4                       ; P2 VECTOR
            GTO [P2-MKSCRCMN]
        ; ELSE
            6
            RCL I                       ; i p1
            IP
            GTO [P2-MKSCRCMN-DONE]
        LBL [P2-MKSCRCMN]
            RCL I                   ; p2
            IP
            8
        LBL [P2-MKSCRCMN-DONE]
        -
        Y^X                         ; i^(6-ip(i))
        RCL (I)                     ; (i)
        9                           ; 9, (i), i^z
        X<Y?                        ; Then we have overflowed
            XEQ [OVERFLOW]
        Rv
        x                           ; i^(6-ip(i)) * $(i)
        STO+ (J)                    ; @(j) += i^(6-ip(i)) + $(i)
        ISG I                       ; i
        SF 3                        ; NOP
    RTN
    ;
    ;OVERFLOW
    LBL [OVERFLOW]
        ; 9, (i), i^z
        X<>Y                        ; (i), 9, i^z
        CLX                         ; 9, i^z
        RCL (J)                     ; vect, 9, i^z
        4000000                     ; 4m, vect, 9, i^z
        MOD                         ; vect, 9, i^z
        LASTX                       ; 4m, vect, 9, i^z
        +                           ; 4m+vect, 9, i^z
        STO (J)                     ; 
    RTN
    ;
    ; Pick a pit to move
    LBL [PICK]
        XEQ [DISPLAY]
        STOP
        CF 4
        IP ; INT
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
            1
            RCL I                      ; i++ (MOVE REGISTER FORWARD)
            +
            14
            MOD
            STO I                       ; i=(i+1)MOD(14)
            FS? 1                       ; P1?
                XEQ [SKIP0]             ; SKIP0 IF P1
            FS? 2
                XEQ [SKIP7]             ; SKIP7 IF P2
            ; INCI END-SUBROUTINE-INLINE
            1
            STO+ (I)                    ; (i)=(i)+1
            DSE J                       ; j--
        GTO [MOVE-LOOP]
        1
        RCL (I)
        X=Y?
            XEQ [WIN-BEANS]
        XEQ [CHECK-ZPITS]
        FS? 3
            XEQ [SWEEP-PITS]
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
        14                              ; 14, i=4
        STO J                           ; 14, i=4, j=14
        RCL I                           ; 4, 14
        STO- J                          ; 4, 14, i=4, j=10
        X=0?
            RTN
        7
        X=Y?                            ; 7, 4, 14
            RTN
        RCL (J)                         ; 10, 7, 4, 14
        X=0?
            RTN
        Rv                              ; 7, 4, 13, 10
        FS? 1
            GTO [P1-WINBEANS]
        FS? 2
            GTO [P2-WINBEANS]
        RTN
        LBL [P1-WINBEANS]
            STO J                       ; i=4, j=7
            X<Y?                       ; 7 < I ?
                RTN
            GTO [DONE-WINBEANS]
        LBL [P2-WINBEANS]
            0
            STO J
            Rv
            X>Y?
                RTN
        LBL [DONE-WINBEANS]
        CLX
        X<> (I)
        STO+ (J)
        CLX
        14
        X<>Y
        -
        STO I
        0
        X<> (I)
        STO+ (J)
    RTN
    ;
    ; Check for zero'd pits on a player's side
    LBL [CHECK-ZPITS]
        1.006
        STO J
        CLST
        LBL [LOOP-ZPITS]
            RCL (J)
            +
            ISG J
            GTO [LOOP-ZPITS]
        X=0?
            SF 3
        14
        RCL J
        X>Y?
            RTN
        8.013
        STO J
        CLST
        GTO [LOOP-ZPITS]
    RTN
    ;
    ;
    LBL [SWEEP-PITS]
        1.006
        STO I
        CLST
        LBL [LOOP-SWEEP]
            0
            X<> (I)
            +
            ISG I
            GTO [LOOP-SWEEP]
        14
        RCL I
        X>Y?
        GTO [P2-SWEEP]
        ;P1-SWEEP
            Rv
            Rv
            STO+ (I)
            8.013
            STO I
            CLST
            GTO [LOOP-SWEEP]
        GTO [DONE-SWEEP]
        LBL [P2-SWEEP]
            CLX
            STO I
            Rv
            Rv
            STO+ (I)
        LBL [DONE-SWEEP]
        CF 3
        CF 4
    RTN
    ;
    ; Display the score
    LBL [DISPLAY]
        14
        STO I
        15
        STO J
        1
        FS? 2
        2
        RCL (J)                         ; P2
        RCL (I)                         ; P1
#41c    FS? 2
#41c        X<>Y
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
        XEQ [DISPLAY]               ; Display the game board
        CF 1
        CF 2
        CF 3
        CF 4
        FIX 4
        DEG
    RTN
END

LBL "MANCA"
    ;Main Mancala program
        XEQ [INIT]
        LBL [MAIN]
            XEQ [CHECK-WINNER]
            FS? 3
            GTO [DONE]
            LBL [REDISPLAY]
            XEQ [DISPLAY]
            XEQ [PICK]
            FS? 4
            GTO [REDISPLAY]
            XEQ [MOVE]
            XEQ [SWITCH]
        GTO [MAIN]
        LBL [DONE]
        XEQ [CLEANUP]
    RTN
    ;
    ; .Init registers
    LBL [INIT]
        CF 1
        CF 2
        CF 3
        CF 4
        13
        STO I      		; i
        4
        LBL [INIT-LOOP]
        STO (I)  		; 4->(i)
        DSE I      		; DSE i
        GTO [INIT-LOOP]
        0
        STO (I)  		; 0->(i), i = 0
        7
        STO I
        X<>Y
        STO (I)  		; 0->(i), i = 7
        SF 1        		; P1'S Turn
        GRAD        		; 42s Only, P1 indicator
    RTN
    ;
    ; Check for winner
    LBL [CHECK-WINNER]
        CF 3                ; Clear winner found flag
        0
        STO J              ; j
        7
        STO I              ; i
        24
        RCL (I)          ; (i)
        X>=Y?
        GTO [P1-WINNER]
        X<>Y
        RCL (J)          ; (j)
        X>Y?
        GTO [P2-WINNER]
        GTO [WINNER-RTN]
        LBL [P1-WINNER]
            "Player 1 won!"
            GTO [WINNER-DONE]
        LBL [P2-WINNER]
            "Player 2 won!"
        LBL [WINNER-DONE]
            SF 3            ; Set winner found flag
            PROMPT
        LBL [WINNER-RTN]
    RTN
    ;
    ; Display the board
    LBL [DISPLAY]
        1.006
        STO I              ; i
        14
        STO J              ; "$(j)" == "$(14)"
        1000000.0
        STO (J)          ; (j)=1,000,000
        LBL [P1-BOARD]
            ;STOP
            10.0            ; WARN Base 10 for now
            6
            RCL I          ; .I
            IP
            -
            Y^X             ; i^(6-ip(i))
            RCL (I)      ; (i)
            x               ; i^(6-ip(i)) * $(i)
            STO+ (J)     ; @(j) += i^(6-ip(i)) + $(i)
            ISG I          ; i
        GTO [P1-BOARD]
        15
        STO J              ; j = P2-vector
        1000000.0
        STO (J)
        13.007
        STO I
        LBL [P2-BOARD]
            ;STOP
            10.0            ; WARN Base 10 for now
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
        STO I              ; i = P1-vector
        ;                   ; 42s only code begin
        FIX 2
        RCL 7                   ; P1 SCORE
        100
        /
        STO+ (I)             ; P1 VECTOR
        RCL 0
        100
        /
        STO+ (J)             ; P2 VECTOR
        ;                   ; 42s only code end
        RCL (J)          ; P2
        RCL (I)          ; P1
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
        STO I              ; i=PICK
        FS? 1
        GTO [CHECK-PICK]
        14
        X<>Y
        -
        STO I              ; i
        LBL [CHECK-PICK]
        RCL (I)          ; (i)
        X=0?
        SF 4
        LBL [PICK-DONE]
        RCL I              ; i
    RTN
    ;
    ; Move beans from selected pit
    LBL [MOVE]
        0
        X<> (I)          ; (i)= 0 (MOVE BEANS OUT)
        STO J              ; j=VALUE PREVIOUSLY IN (i)
        LBL [MOVE-LOOP]
        ; .INCI SUBROUTINE-INLINE
            1
            RCL+ I         ; i++ (MOVE REGISTER FORWARD)
            14
            MOD
            STO I           ; i=(i+1)MOD(14)
            FS? 1           ; P1?
            XEQ [SKIP0]     ; SKIP0 IF P1
            FS? 2
            XEQ [SKIP7]     ; SKIP7 IF P2
        ; .INCI END-SUBROUTINE-INLINE
        1
        STO+ (I)         ; (i)=(i)+1
        DSE J            ; j--
        GTO [MOVE-LOOP]
    RTN
    ;
    ; SKIP0
    LBL [SKIP0]
        X=0?
        ISG I
        CF 0            ; NOP
    RTN
    ;
    ; SKIP7
    LBL [SKIP7]
        7
        X<>Y
        X=Y?
        ISG I
        CF 0            ; NOP
    RTN
    ;
    ; Switch to other players turn
    LBL [SWITCH]
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

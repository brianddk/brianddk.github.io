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
    ; Init registers
    LBL [INIT]
        CF 1
        CF 2
        CF 3
        CF 4
        13
        STO 16      		; I
        4
        LBL [INIT-LOOP]
        STO IND 16  		; 4->(I)
        DSE 16      		; DSE I
        GTO [INIT-LOOP]
        0
        STO IND 16  		; 0->(I), I = 0
        7
        STO 16
        X<>Y
        STO IND 16  		; 0->(I), I = 7
        SF 1        		; P1'S Turn
        GRAD        		; 42s Only, P1 indicator
    RTN
    ;
    ; Check for winner
    LBL [CHECK-WINNER]
        CF 3                ; Clear winner found flag
        0
        STO 17              ; J
        7
        STO 16              ; I
        24
        RCL IND 16          ; (I)
        X>Y?
        GTO [P1-WINNER]
        X<>Y
        RCL IND 17          ; (J)
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
        STO 16              ; I
        14
        STO 17              ; @(J) == @(14)
        0
        STO IND 17          ; (J)=0
        LBL [P1-BOARD]
            ;STOP
            10.0            ; WARN Base 10 for now              
            6
            RCL 16          ; I
            IP
            -
            Y^X             ; 16^(6-ip(i))
            RCL IND 16      ; (I)
            x               ; 16^(6-ip(i)) * @(i)
            STO+ IND 17     ; @(j) += 16^(6-ip(i)) + @(i)
            ISG 16          ; I
        GTO [P1-BOARD]
        15
        STO 17              ; J = P2-vector
        0
        STO IND 17
        13.007
        STO 16
        LBL [P2-BOARD]
            ;STOP
            10.0            ; WARN Base 10 for now
            RCL 16
            IP
            8
            -
            Y^X
            RCL IND 16
            x
            STO+ IND 17
            DSE 16
        GTO [P2-BOARD]
        14
        STO 16              ; I = P1-vector
        ;                   ; 42s only code begin
        FIX 2
        RCL 7                   ; P1 SCORE
        100
        /
        STO+ IND 16             ; P1 VECTOR
        RCL 0
        100
        /
        STO+ IND 17             ; P2 VECTOR
        ;                   ; 42s only code end
        RCL IND 17          ; P2
        RCL IND 16          ; P1
        STOP
    RTN
    ;
    ; Pick a pit to move
    LBL [PICK]
    RTN
    ;
    ; Move beans from selected pit
    LBL [MOVE]
    RTN
    ;
    ; Switch to other players turn
    LBL [SWITCH]
    RTN
    ;
    ; Clean up after game
    LBL [CLEANUP]
    RTN
END

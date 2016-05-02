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
    RTN
    ;
    ; Display the board
    LBL [DISPLAY]
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

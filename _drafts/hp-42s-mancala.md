---
layout: post
title:  "hp35s Software"
#date:   2016-05-04 17:20 -0500
categories: calc hp42s hp35s
---
This is a mancala program I wrote for the hp42s (Free42).  For those not familiar with mancala, its a very achient game that has become repopularized over the last few years in the US.  You can now get a mancala board at most stores that sell board games.  This particular 'flavor' of mancala kahla(6,4), but it seemed to be the one that is most available in my area.  This is a fun game to play, but most mathmatical analysis of possible permutations make this game signifigantly harder for Player 2.  Whoever goes first is likely to win.

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
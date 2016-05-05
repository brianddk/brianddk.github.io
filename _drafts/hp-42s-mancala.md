---
layout: post
title:  "hp35s Software"
#date:   2016-05-04 17:20 -0500
categories: calc hp42s hp35s
---
This is a mancala program I wrote for the hp42s (Free42).  For those not familiar with mancala, its a very achient game that has become repopularized over the last few years in the US.  You can now get a mancala board at most stores that sell board games.  This particular 'flavor' of mancala kahla(6,4), but it seemed to be the one that is most available in my area.

### HP 35s Portable
The primary listing is in an '.asm' file that I put through a very gentle pre-processor.  This was simply done to keep all the LBL, XEQ, GTO statements synced up.  I prefer verbose label names, but that has a tendency of poluting your program catalog with all your 'subroutines'.  The pre-processor will take marked-up verbose labels and convert them to 42s local-labels that don't appear in the catalog.  I have also choosen to use no named variables for similar reasons.  Since I plan to port this to the 35s, I choose to only access registers indirectly.  This is the only way that the 35s can access un-named registers, so enforcing this makes the porting a breeze.  References to I, (I), J, and (J), are all 35s notation.


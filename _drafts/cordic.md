---
layout: post
title:  "How Calculators Work"
#date:   2016-04-23 23:50 -0500
categories: calc hp35s
---
Trying to understand how calculators work lead to research on CORDIC and log tables.  The following are some *bread crumbs* related to that research

1. [CORDIC Trig approximations](https://en.wikipedia.org/wiki/CORDIC)
2. [CORDIC for dummies](http://home.citycable.ch/pierrefleur/Jacques-Laporte/cordic_for_dummies.htm)
2. [Calculate exp() and log() with tables](http://www.quinapalus.com/efunc.html)
3. [Henry Briggs and the HP35](http://home.citycable.ch/pierrefleur/Jacques-Laporte/Briggs%20and%20the%20HP35.htm)
4. [A reconstruction of the tables of Briggs' Arithmetica logarithmica](https://hal.inria.fr/inria-00543939/document)
5. [Methods to Approximate Roots](https://en.wikipedia.org/wiki/Methods_of_computing_square_roots) - aka. How did Briggs calc roots?
6. [Using CORDIC methods for computation in micro-controllers](http://www.siue.edu/~gengel/pdf/cordic.pdf) - best paper ever!!

From [3], we can derive the following functions...

1. x*y = exp(ln(x) + ln(y))
2. x/y = exp(ln(x) - ln(y))
3. y^x = exp(x*ln(y)) = exp(exp(ln(ln(y))) + ln(x))

From [2], we can derive `sin`, `cos`, and `tan` for any angle

1. tan(a) = sin(a)/cos(a)
2. sin(a) = tan(a)/sqrt(1+tan(a)^2)
3. cos(a) = 1/sqrt(1+tan(a)^2)

Also remember that the implied multiplication and division in [2] and [3] can be replaced with shift operations if the the proper base is chosen.  This means that all major math functions can be reduced to shift, add and subtract.

Some other reading to get back to
1. [The Machine (1909)](http://archive.ncsa.illinois.edu/prajlich/forster.html)
2. [SendKeys Method](https://msdn.microsoft.com/en-us/library/8c6yea83%28v=vs.84%29.aspx)
3. [SendInput Method](https://msdn.microsoft.com/en-us/library/windows/desktop/ms646310%28v=vs.85%29.aspx)
4. [SendInput Powershell](https://www.reddit.com/r/PowerShell/comments/3qk9mc/keyboard_keypress_script/)

Listings

35s

```
;A = STKy
;N = STKx
N001 LBL N      ; stack(x,y,z,t) = N,A,?,?
N002 eqn IP(XROOT(REGX,REGY))
N003 X!=0?      ; x0,n,a,?
N004 GTO N007   ; If x0 < 1, x0=1
N005 CLX        ; 0,n,a
N006 1          ; 1,n,a, x0=1 case
N007 eqn REGZ-REGX^REGY
N008 Rv         ; x0,n,a,y
N009 eqn REGX+REGT/(REGY*REGX^(REGY-1))
N010 STOP       ; xk,xk-1,n,a
N011 X<>Y       ; prepare to dump xk-1
N012 CLX        ; 0,xk,n,a
N013 eqn INV(REGZ)*((REGZ-1)*REGY+REGT/(REGY^(REGZ-1)))
N014 GTO N010   ; xi,xi-1,n,a (where k+1 = i)
```

Focal

```
01 LBL "NEWT"  15 RCL 00      29 RCL 02      43 RCL 00
02 STO 00      16 Y^X         30 +           44 1
03 X<>Y        17 RCL 01      31 LBL 01      45 -
04 STO 01      18 X<>Y        32 RCL 02      46 RCL 02
05 X<>Y        19 -           33 X<>Y        47 *
06 1/X         20 STO 03      34 STO 02      48 +
07 Y^X         21 RCL 02      35 STOP        49 RCL 00
08 INT         22 RCL 00      36 RCL 00      50 1/X
09 X!=0?       23 1           37 1           51 *
10 GTO 00      24 -           38 -           52 GTO 01
11 CLX         25 Y^X         39 Y^X         53 RTN
12 1           26 RCL 00      40 RCL 01      54 END
13 LBL 00      27 *           41 X<>Y
14 STO 02      28 /           42 /
```

35s Cordis Multiply

```
M001 LBL M             M018 SF 0              M035 GTO M037
M002 CF 0              M019 1                 M036 GTO M016
M003 STO X             M020 STO- I            M037 CF 0
M004 CLx               M021 FS? 0             M038 CLX
M005 STO Z             M022 +/-               M039 Z*J
M006 STO I             M023 CF 0              M040 RTN
M007 STO J             M024 eqn X+REGX*2^I    M041 IP
M008 X<>Y              M025 STO X             M042 X=0?
M009 XEQ M041          M026 X=0?              M043 GTO M050
M010 STO Y             M027 SF 0              M044 1
M011 RCL X             M028 eqn Z*J           M045 STO+ J
M012 XEQ M041          M029 eqn Z-REGZ*Y*2^I  M046 LASTX
M013 STO X             M030 RCL* J            M047 2
M014 eqn 2^J           M031 STOP              M048 /
M015 STO J             M032 LASTX             M049 GTO M041
M016 RCL X             M033 STO Z             M050 LASTX
M017 X>0?              M034 FS? 0             M051 RTN
```

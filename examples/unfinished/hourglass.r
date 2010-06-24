; http://stackoverflow.com/questions/1683857/code-golf-hourglass

; UNFINISHED: For the moment this just draws the hourglass, and calculates volume, 
; no sand...

; read J from the user, this is our height which will be greater than 1
;rJ
JfsA

; read N from the user, this is our percentage sand
;N 0% rN
NscA

; top line width is what we get when add 1 to the result of multiplying j * 2
Wad1mpJ2

S{ \/_} ; sides string

V0

; D is how far we need to inDent
D0

; draw the top line; it's an outlier, use string constructor
prS^w{_}

; Print is a a|function for printing volumed character runs
; A is the character
; W is assumed as the width
Pa|[pnS^dSPpnSCsLOw[pnA]prTHs]

; inner width starts out as two less
Ls+W2

; Hourglass func takes two parameters...A is the limit for the draw, and B is the 
; offset (-1 for top half, 1 for bottom)
Hb~[
	u[
		a+Vw
		Ze?Wa
		pEz[fsS]sp
		eZ1[s+DbA+wMPb2no]
	]
]

; print top half
h1 -1
; reverse the side stringmap
rvS
; print bottom half
hL1
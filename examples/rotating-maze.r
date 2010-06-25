; http://stackoverflow.com/questions/3034331/code-golf-rotating-maze

; We use "first" and "second" a lot, worth it to define f and s
.fFS.sSC

; character set
L{#o@}
	
; copy input to matrix, or read file if it's a filename
MeFI?a[rlA]a
	
; define data width and height functions
; Note: we don't use while loops so this shows an overwriting of w
; if while is needed it's still available under WT (while-true?-mu)
W|[l?Fm]
H|[l?M]
	
; size function (accounts for applied rotations)
Z|[Tre[wH]iOD?j[rvT]t]
	
; cell retrieval function (accounts for applied rotations)
Ca|[
	st[xY]a
	KrePC[[yBKx][ntSBhXbkY][ntSBhYsbWx][xSBwY]]ntJ
	skPCmFkSk
]
	
; grid enumerator function, does a callback for every coordinate pair in
; the grid (accounts for rotation).  Every cell will be visited
; unless a logically true result is given from the callback
; which will short circuit
Ga|[rtYsZ[rtXfZ[TaRE[xY]iTbr]iTbr]rnT]
	
; find the ball, or none (uses the each method above)
B|[gA|[ieSClFcA[rnA]]]

; forever...
fv[
	NbIn[
		un[		
		    ++N/2
		    TfCn
			ieFlTbr
			chCbSP
			ieTHlTbr
			chCnSl
			=~SnSz
		]
	]
	
	; print the maze
	gA|[TfCaEEfZfA[prT][pnT]nn]
	
	; unless ball position is still not none, we'll be exiting the loop...
	utBbr
	
	; Update the rotation value based on the input
	JmoADjPC[3 1]rK4   
]

; http://stackoverflow.com/questions/3034331/code-golf-rotating-maze

; We use "first" and "second" a lot, worth it to define f and s
.fFR.sSC

; character set
L{#o@}
	
; copy input to matrix, or read file if it's a filename
MeFI?a[rlA]a
	
; define data width and height functions
W|[l?Fm]
H|[l?M]
	
; size function (accounts for applied rotations)
Z|[Tre[wH]iOD?j[rvT]t]
	
; cell retrieval function (accounts for applied rotations)
C|a[
	st[xY]a
	KrePC[[yBKx][ntSBhXbkY][ntSBhYsbWx][xSBwY]]ntJ
	skPCmFkSk
]
	
; grid enumerator function, does a callback for every coordinate pair in
; the grid (accounts for rotation).  Every cell will be visited
; unless a logically true result is given from the callback
; which will short circuit
G|a[rtYsZ[rtXfZ[TaRE[xY]iTbr]iTbr]rnT]
	
; find the ball, or none (uses the each method above)
B|[g |a[ieSClFcA[rnA]]]

; forever...
fv[
	NbIn[
		ut[		
		    ++N/2
		    TfCn
			ieFlTbr
			chCbSP
			ieTHlTbr
			chCnSl
			e?SnSz
		]
	]
	
	; print the maze
	g |a[TfCaEEfZfA[prT][pnT]nn]
	
	; if ball has vanished, we're done
	iNN?bBR
	
	; Update the rotation value based on the input
	JmoADjPC[3 1]rK4   
]

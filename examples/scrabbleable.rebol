; http://stackoverflow.com/questions/2261681/code-golf-scrabble-able/

; we use the space constant a lot, so it's worth it to define s to be space
Ssp

; N is the number of input strings
Nl?A
   
; L is our longest string length
L00feZa[LmxLl?Z]

; V is our board size
; expression is V(1 + (l - 1) * (ad eOD?n1[0] dv n 2)])
; we add one because our loop doesn't do the theoretical minimum ++ v
Va2mpBKlADeOD?n01[0]d2N
	
; M is our VxV board matrix, initially set to spaces 
print v
print s
Mai^Vsi^Vs
	
; G is a func (not a funct) thus can write to the global variable M 
; it takes a matrix to replace the matrix with and returns the old one 
Ga&[ZcydM MaZ]
	
; F is the now common iterator finder for coordinates in a matrix
; modified so if you ask about out of range it always returns space
Fa|[ZpcMscA XfsA ZigX00[iZ[skZbkX]] iZ[iT?z[Zno]]eZz{ }]
	
; T is a "c|function", meaning it takes parameters A B C
; it tries to put the string A into the matrix at coordinates B with step offset C
; returns true if successful false if not
; NOTES: as written, will corrupt the board in the case of a failure, so save a copy
; (for horizontal placemement C = [1 0] and vertical placement C = [0 1])
; rule is that any non-space must match the word we're putting down
; also at least one such collision must happen for a true result
; (ignored by the first word placement)
; also we cannot make a continuation of an existing word
; (before first letter and after last must be space or board edge)
; points opposite a collision may be occupied on the other axis, but if there's
; not a collision then those points must be spaces
Tc|[
	Xno
	Q&[Z01br]
	ieSfsFsbBc[w[Zf+A][JfB KfsJeeSk[OrvCYcEEsFSfADbO[eeSfsFadBngO[chJz]q]q][X01iuKzQ]BadBc]ieSfsFb[f~Xz]]
]
	
; R recursively applies itself for placing the words in A
; returns true if it succeeds
Ra|[
	Q&[iUbr]
	eT?aON[
		ZnxSBvL
		rtXz[
			rtYz[
				O[0 1]
				lo 2[
					JgM ; save matrix copy
					UeTfsAre[xY]o[rNXa][eH?a[rNXa]no]
					eU00[gJ]
					rvO
					q
				]
				q
			]
			q
		]
		u
	]
]

; Print the result
eRa[
	; if r(a) returned true... then
	
	; clean up the unneccessary whitespace on the board
	JmW[Kf+J][iM?trtK[JbkJtkJ]]
	
	; and injects i|n|t|e|r|m|e|d|i|a|t|e pipe characters as per problem spec
	feZm[Kf+Zw[Jf+Z][ZnxISbkZegKs[egJs{|}s]s Kj]prHDz]
][
	; otherwise print false
	pr{false}
]
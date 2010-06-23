; http://stackoverflow.com/questions/2527477/code-golf-connecting-the-dots/

; copy program argument into variable (m)atrix
Ma

; string containing the (l)etters used for walls
L{-|\/}

; q is a "b|function" (function that takes two parameters, a and b)
; it gives you the sign of subtracting b from a (+1, -1, or 0)
Q|b[sg?SBaB]

; d finds you the iterator position of the first digit of a two digit
; number in the matrix
D~a[feSm[TfiSrj[spAsp]iT[++Tbr]]t]

; given an iterator position, this tells you the x coordinate of the cell
X|a[i?A]

; given an iterator position, this tells you the y coordinate of the cell
Y|a[i?FImHDa]

; pass in a coordinate pair to c and it will give you the iterator position
; of that cell
C|a[skPCmSCaBKfrA]

; n defaults to 1 in Rebmu.	 we loop through all the numbers up front and
; gather their coordinate pairs into a list called g
wh[Jd++N][roG[xJyJ]]

; b is the (b)eginning coordinate pair for our stroke, we get it from g and
; advance g's iteration position (fp="first+")
BfpG

whB[
	; j is the iterator position of the beginning stroke
	JcB
	
	; f is the (f)inishing coordinate pair for our stroke
	FfpG
	
	; if there is a finishing pair, we need to draw a line 
	iF[
		; k is the iterator position of the end of the stroke
		KcF
		
		; the (h)orizontal and (v)ertical offsets we'll step by (-1,0,1)
		HqXkXj
		VqYkYj
		
		; change the character at iterator location for b (now our
		; current location) based on an index into the letters list
		; that we figure out based on whether v is zero, h is zero,
		; v equals h, or v doesn't equal h.
		u[
			; if we update the coordinate pair by the offset and it 
			; equals finish, then we're done with the stroke
			chCbPClEZv1[ezH2[eeHv3 4]]
			e? BadBre[hV]f
		]
	]
	
	; whether we overwrite the number with a + or a plus and space
	; depends on whether we detect one of our wall "letters" already
	; one step to the right of the iterator position
	chJeFIlSCj{+}{+ }
	
	; update from finish pair to be new begin pair for next loop iteration
	Jk
	Bf
]

; write out m
wM
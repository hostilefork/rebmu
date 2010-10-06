; http://stackoverflow.com/questions/372668/code-golf-how-do-i-write-the-shortest-character-mapping-program

; try with:
; rebmu/args %character-mapping.r ["EncodeMe" "e,f|M,N|c,d|n,m|E,F|o,p|d,e"]

ScyFSaFE[fCtU]scA[DfsAw[Kf+S Jf+D][iAL[==~Jk==~Kf][chBKsT]]hd+S]prS

comment [
; >> unmush [ScyFSaFE[fCtU]scA[DfsAw[Kf+S Jf+D][iAL[==~Jk==~Kf][chBKsT]]hd+S]prS]
; == [s: cy fs a fe [f c t u] sc a [d: fs a w [k: f+ s j: f+ d] [i al [==~ j k ==~ k f] [ch bk s t]] hd+ s] pr s]

	; Make a copy of the first element of our argument array
	s: cy fs a 

	; foreach can take a block of series elements to iterate with, this does four at a time
	; taken from the second element of the arguments list (sc a)
	;
	; the characters are (F)rom, (C)omma, (T)o, and (U)nderscore
	; ...though only from and to interest us
	fe [f c t u] sc a [

		; make d point to the first element of our argument list (string to encode)
		d: fs a
		
		; while we can pick the first elements off of both s and d without 
		; reaching the end of the strings...
		w [k: f+ s j: f+ d] [
			; if all conditions of equality apply, namely that the character
			; in this position from the original hasn't changed since we started
			; and the current character is equal to the "from" character...
			i al [==~ j k ==~ k f] [
				; then change the last (back) character in the series S to the
				; to character
				ch bk s t
			]
		]
		
		; reset s to the series head position (+ functions modify their arguments)
		hd+ s
	]
	pr s
]
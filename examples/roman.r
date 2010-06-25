; http://stackoverflow.com/questions/1839079/can-this-roman-number-to-integer-converter-code-be-shorter

; Implementation of Roman Numeral to Decimal converter.  (It was the first Rebmu program,
; written before an interpreter existed!)

; read string
rS

; j and k both start out at zero

; foreach character in string
feCs[
	; select value N according to word conversion of C
	; Note: have to start with X because otherwise the x would require a space in order
	; to avoid unmushing as a pair (i.e [i1x10] turns into [i 1x10] instead of [i1 x10])
	Nse[x10i1v5l50c100d500m1000]twC
	
	; unless J is zero, do the sum step
	uzJ[
		; K is the sum of K and, if J < N, N - J (while setting N to 0) or otherwise j 
		a+KelJn[asSBnJ N0]j
	]
	
	; assign n to j
	Jn
]

; return sum of k and j
adKj

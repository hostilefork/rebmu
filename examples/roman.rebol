; http://stackoverflow.com/questions/1839079/can-this-roman-number-to-integer-converter-code-be-shorter

; Implementation of Roman Numeral to Decimal converter.  (It was the first Rebmu program,
; written before an interpreter existed!)

; read string
rS

; j and k both start out at zero

; foreach character in string
feCs[
	; select value N according to word conversion of C
	Nse[I01V05X10L50C100D500M1000]twC
	
	; unless J is zero, do the sum step
	uzJ[
		; K is the sum of K and, if J < N, N - J (while setting N to 0) or otherwise j 
		a+KelJn[asSBnJ N00]j
	]
	
	; assign n to j
	Jn
]

; return sum of k and j
adKj

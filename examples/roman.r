; http://stackoverflow.com/questions/1839079/can-this-roman-number-to-integer-converter-code-be-shorter

; Implementation of Roman Numeral to Decimal converter.  (It was the first Rebmu program,
; written before an interpreter existed!)

; read string
rS

; j and k both start out at zero

; foreach character in string
feCs[
	; select value N according to word conversion of C
	; Note: have to start with x10 because 5x10 unmushes as a pair
	Nse[x10i1v5l50c100d500m1000]twC
	
	; if J is zero, assign N to J and continue
	izJ[JnCN]
	
	; K is the sum of K and, if J < N, N - J (while setting N to 0) or otherwise j 
	KadKelJn[alSBnJ N0]j
	
	; assign n to j
	Jn
]

; return sum of k and j
adKj

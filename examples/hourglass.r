; http://stackoverflow.com/questions/1683857/code-golf-hourglass


; read J from the user, this is our height which will be greater than 1
; NOTE: if we are using rebmu/args we'd do JfsA
rJ

; read N from the user, this is our percentage sand
; NOTE: if we are using rebmu/args we'd do NscA
; NOTE: Percentages are a new type introduced in Rebol 3, this won't work in Rebol 2
N 0% rN

; Here's a doomsday hourglass... it tells you how much of your life is left until 21-dec-2012
; Demonstrates how native Rebol code can be used natively right smack dab in the middle of Rebmu.

comment [
	birthday: to-date (ask "When were you born? ")
	
	; Note: use difference function for more precise result than days
	n: (21-dec-2012 - now/date) / (21-dec-2012 - birthday)
]

; top line width is what we get when add 1 to the result of multiplying j * 2
Wad1mpJ2

; S is a string whose elements correspond to:
;
; 1: what to print if there's no volume and it's the last row
; 2: left boundary of hourglass
; 3: sand
; 4: right boundary of hourglass
; 5: what to print when there is no volume and it's not the last row
;
; Reversing it makes it work for the bottom half when you change the first 
; character to an underscore
S{ \x/ }

; D is how far we are currently inDented during a print
D0

; Hourglass func takes three parameters...
; A is the limit for the draw
; B is the count of the volume of *spaces* to draw before we start drawing X characters
; C is our offset (-1 for top half, 1 for bottom)
Hc&[
	u[
		; z says are we on the last line we are to print?
		Ze?Wa
		
		; start Q initialized as an empty string, and then fill it using "sand physics"
		; dropping on the sides using alternating append/insert (if top) or repeatedly
		; inserting at midpoint (if bottom)
		Qs^RTkW[isEL0c[skQdvK2][eEV?kQ[tlQ]]pcSeg--B0[eZ1 5]3]
		
		; rejoin a string composed of an indentation of length d, the left hourglass
		; side, the Q string, and the right hourglass side.
		prRJ[si^DspSCsQfhS]
		
		; loop termination condition and continuation
		eZ1[s+DcA+wMPc2no]
	]
]

; V is the volume function, pass it a percentage and it will tell you
; how many spaces need to be drawn in order to be that capacity
Va|[mpAj**2]

; draw the top line; it's an outlier, use string constructor
prSI^w{_}

; inner width at widest point starts out as two less
Ls+W2

; print top half
h1tiVsb1n -1

; reverse the stringmap and change first character to underscore
chRVs{_}

; print bottom half
hLceVn1
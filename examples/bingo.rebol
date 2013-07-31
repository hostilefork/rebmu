; http://codegolf.stackexchange.com/questions/8501/code-golf-bingo

; this solution is based on a flattening that builds up a sequence of all
; the winning combinations into a sequence.  every fifth element
; in the sequence G represents a solution.  using the rather obvious trick
; of substituting a picked number with an asterisk, it is only necessary
; to find a series of 5 asterisks in this expanded set which starts on
; one of these boundaries

; store the number five since we use it a lot and it's not, "Size"
S05

; RepeaT this loop five times, with variable Z counting 1 to 5
rtZs[
	; a trick that helps reduce the number of loops is that the 5-line input loop
	; actually builds the diagonal solutions.  as it proceeds it inserts one at
	; the beginning and appends the other as it goes.  so if the first line of your
	; bingo board is "14 29 38 52 74", then after that input you will have:
	;
	;      [14 14 29 38 52 74 74]
	;
	; then if the second line of your bingo board is "4 18 33 46 62", you'll get:
	;
	;      [18 14 4 18 33 46 62 14 29 38 52 74 74 46]
	;
	; at this stage, two of the five forward diagonal numbers have been inserted at
	; the head, while two of the five reverse diagonal numbers are appended at the tail.
	; because the series of five are checked and order does not matter, the natural
	; choice of insert and append are used.  the final state will have G contain
	; the five horizontal lines bookended by the series of five values that make
	; the diagonal
	;
	; we also build a vector of five asterisk literals in V, so long as we loop x5

	GisGpcRaZisGaAPgPCaSB06zAPv'*
]

; our second loop is nested, with the job of capturing the vertical winning solutions
; and appending them to the list as new sequences of 5 values.  Each iteration of
; the outer loop appends one vertical solution
lS[
	; we start by assigning A to point to G, which starts with pointing at the first
	; element of a non-diagonal row in our series.  Then we loop five times to append
	; the vertical to the list by skipping five elements at a time
	AgLs[
		apGfAsk+aS
	]

	; we advance the G pointer to the next first element of a non-diagonal row, to
	; be copied into A and skipped by fives again.
	f+G
]

; reset G to head, and "until" the block evaluates to something true, we loop...
hd+Gu[
	; this simply does a replace/all in our sequence for any occurrence of the integer
	; portion of the string we read from the user...putting an asterisk in the place
	; a number is found.  Then we just use find with a skip value of 5 on the vector
	; of asterisks we created earlier.
	raGin-NXrM'*FISgVs
]

; print bingo, 'cause we're done...
p"BINGO!"

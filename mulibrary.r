REBOL [
	Title: "Rebol Mu Library"
	Description: {Library of functions used by the Rebmu interpreter, with ordinary long
	names so they could be called by any Rebol code.}
]

to-string-mu: func [
    value
] [
	either any-word? value [
		; This code comes from spelling? from an old version of Bindology
		; Ladislav and Fork are hoping for this to be the functionality of to-string in Rebol 3.0
		; for words (then this function would then be unnecessary).
		
	    case [
	        word? :word [mold :word]
	        set-word? :word [head remove back tail mold :word]
	        true [next mold :word]
	    ]
	] [
		to-string value
	]
]

to-word-mu: func [value] [
	either char? value [
		to-word to-string value
	] [
		to-word value
	]
]

do-mu: func [
    {Is like Rebol's do except does not interpret string literals as loadable code.}
    value
] [    
    either string? :value [value] [do value]
]

if-mu: func [
	{If condition is TRUE, runs do-mu on the then parameter.}
    condition
    then-param
	/else "If not true, then run do-mu on this parameter"
	else-param
] [
	either condition [do-mu then-param] [if else [do-mu else-param]]
]

either-mu: func [
    {If condition is TRUE, evaluates the first block, else evaluates the second.}
    condition
    true-param
    false-param
] [
	either condition [do-mu true-param] [do-mu false-param]
]

either-lesser?-mu: func [
    {If condition is TRUE, evaluates the first block, else evaluates the second.}
	value1
	value2
    true-param
    false-param
] [
	either-mu lesser? value1 value2 true-param false-param
]

make-matrix-mu: funct [columns value rows] [
	result: copy []
	loop rows [
		append/only result array/initial columns value
	]
	result
]

make-string-mu: func [length value] [
	to-string array/initial length value
]

; if a pair, then the first digit is the digit
make-integer-mu: func [value] [
	switch/default type?/word get value [
		pair! [to-integer first value * (10 ** second value)]
		integer! [to-integer 10 ** value]
	] [
		throw "Unhandled type to make-integer-mu"
	]
]

; helpful is a special routine that quotes its argument and lets you pick from common
; values.  for instance helpful-mu d gives you a charaset of digits.  Passing an
; integer into helpful-mu will just call make-integer-mu.  There's potential here for
; really shortening
helpful-mu: func ['arg] [
	switch/default type?/word get arg [
		word! [
			switch/default arg [
				b: [0 1] ; binary digits
				d: charset [#"0" - #"9"] ; digits charset
				h: charset [#"0" - #"9" #"A" - "F" #"a" - #"f"] ; hexadecimal charset
				u: charset [#"A" - #"Z"] ; uppercase
				l: charset [#"a" - #"z"] ; lowercase
			]
		]
		; Are there better ways to handle this?  h2 for instance is no shorter than 20
		integer! [make-integer-mu arg]
		pair! [make-integer-mu arg]
	] [
		throw "Unhandled parameter to make-magic-mu"
	]
]

readin-mu: funct [
	{Use data type after getting the quoted argument to determine input coercion}
	'value
] [
	switch/default type?/word get value [
		string! [set value ask "Input String: "]
		integer! [set value to-integer ask "Input Integer: "]
		decimal! [set value to-integer ask "Input Float: "]
		block! [set value to-block ask "Input Series of Items: "]
	] [
		throw "Unhandled type to readin-mu"
	]
]

; Don't think want to call it not-mu because we probably want a more powerful operator
; defined as ~ in order to compete with GolfScript/etc.
inversion-mu: func [
	value
] [
	either not value [
		true
	] [
		either zero? value [
			true
		] [
			false
		]
	]
]

funct-mu: func [
    "Defines a function with all set-words as locals."
    spec [block! word!] {Help string (opt) followed by arg words (and opt type and string)
    but may be a word in which case the word is just wrapped in a block}
    body [block!] "The body block of the function"
] [
	funct to-block spec body
]
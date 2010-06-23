REBOL [
	Title: "The Mu Rebol Library"
	Description: {These functions are intended to help write Rebol programs that use fewer
	lexical symbols in their source code.  This is a part of the Rebmu interpreter project
	for code golf, but you can program to these routines even if you are not using the
	abbreviated namaes of the routines or the "mushing" protocol of the Rebmu dialect.}
]

to-string-mu: func [
	value
] [
	either any-word? value [
		; This code comes from spelling? from an old version of Bindology
		; Ladislav and Fork are hoping for this to be the functionality of to-string in Rebol 3.0
		; for words (then this function would then be unnecessary).
		
		case [
			word? :value [mold :value]
			set-word? :value [head remove back tail mold :value]
			true [next mold :value]
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

caret-mu: func ['value] [
	switch/default type?/word :value [
		string! [return to-string debase value]
	] [
		throw "caret mu needs to be thought out for non-strings, see rebmu.r"
	]

]

redefine-mu: func ['dest 'source] [
	set :dest get :source 
]

do-mu: func [
	{Is like Rebol's do except does not interpret string literals as loadable code.}
	value
] [
	switch/default type?/word :value [
		block! [return do value]
		word! [
			temp: get value
			either (function? temp) or (native? temp) [
				return do temp
			] [
				return temp
			]
		]
	] [
		return :value
	]
]

if-mu: func [
	{If condition is TRUE, runs do-mu on the then parameter.}
	condition
	'then-param
	/else "If not true, then run do-mu on this parameter"
	'else-param
] [
	either condition [do-mu then-param] [if else [do-mu else-param]]
]

if-greater?-mu: func [
	{If condition is TRUE, runs do-mu on the then parameter.}
	value1
	value2
	'then-param
	/else "If not true, then run do-mu on this parameter"
	'else-param
] [
	either greater? value1 value2 [do-mu then-param] [if else [do-mu else-param]]
]

if-not-equal?-mu: func [
	{If condition is TRUE, runs do-mu on the then parameter.}
	value1
	value2
	'then-param
	/else "If not true, then run do-mu on this parameter"
	'else-param
] [
	either not-equal? value1 value2 [do-mu then-param] [if else [do-mu else-param]]
]

if-equal?-mu: func [
	{If condition is TRUE, runs do-mu on the then parameter.}
	value1
	value2
	'then-param
	/else "If not true, then run do-mu on this parameter"
	'else-param
] [
	either equal? value1 value2 [do-mu then-param] [if else [do-mu else-param]]
]

if-zero?-mu: func [
	{If condition is TRUE, runs do-mu on the then parameter.}
	value
	'then-param
	/else "If not true, then run do-mu on this parameter"
	'else-param
] [
	either zero? value [do-mu then-param] [if else [do-mu else-param]]
]

if-lesser?-mu: func [
	{If condition is TRUE, runs do-mu on the then parameter.}
	value1
	value2
	'then-param
	/else "If not true, then run do-mu on this parameter"
	'else-param
] [
	either lesser? value1 value2 [do-mu then-param] [if else [do-mu else-param]]
]

either-mu: func [
	{If condition is TRUE, evaluates the first block, else evaluates the second.}
	condition
	'true-param
	'false-param
] [
	either condition [do-mu true-param] [do-mu false-param]
]

either-zero?-mu: func [
	{If condition is ZERO, evaluates the first block, else evaluates the second.}
	value
	'true-param
	'false-param
] [
	either zero? value [do-mu true-param] [do-mu false-param]
]

either-greater?-mu: func [
	{If condition is TRUE, evaluates the first block, else evaluates the second.}
	value1
	value2
	'true-param
	'false-param
] [
	either greater? value1 value2 [do-mu true-param] [do-mu false-param]
]

either-lesser?-mu: func [
	{If condition is TRUE, evaluates the first block, else evaluates the second.}
	value1
	value2
	'true-param
	'false-param
] [
	either lesser? value1 value2 [do-mu true-param] [do-mu false-param]
]

either-equal?-mu: func [
	{If values are equal runs do-mu on the then parameter.}
	value1
	value2
	'true-param
	'false-param
] [
	either equal? value1 value2 [do-mu true-param] [do-mu false-param]
]

while-mu: func [
	'cond-param
	'body-param
] [
	while [do-mu cond-param] [do-mu body-param]
]

while-greater?-mu: func [
	'value
	'cond-param
	'body-param
] [
	while [greater? do-mu value do-mu cond-param] [do-mu body-param]
]

while-lesser-or-equal?-mu: func [
	value
	'cond-param
	'body-param
] [
	while-mu [lesser-or-equal? value do-mu cond-param] [do-mu body-param]
]

while-greater-or-equal?-mu: func [
	value
	'cond-param
	'body-param
] [
	while [greater-or-equal? value do-mu cond-param] [do-mu body-param]
]

while-lesser?-mu: func [
	value
	'cond-param
	'body-param
] [
	while-mu [lesser? value do-mu cond-param] [do-mu body-param]
]


while-equal?-mu: func [
	value
	'cond-param
	'body-param
] [
	while [equal? value do-mu cond-param] [do-mu body-param]
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
		; Are there better ways to handle this?	 h2 for instance is no shorter than 20
		integer! [make-integer-mu arg]
		pair! [make-integer-mu arg]
	] [
		throw "Unhandled parameter to make-magic-mu"
	]
]

; An "a|funct" is a function that takes a single parameter called a, you only
; need to supply the code block.  obvious extensions for other letters.	 The
; "func|a" is the same for funcs

funct-a-mu: funct [body [block!]] [
	funct [a] body 
]
funct-ab-mu: funct [body [block!]] [
	funct [a b] body 
]
funct-abc-mu: funct [body [block!]] [
	funct [a b c] body 
]
funct-abcd-mu: funct [body [block!]] [
	funct [a b c d] body 
]

funct-z-mu: funct [body [block!]] [
	funct [z] body 
]
funct-zy-mu: funct [body [block!]] [
	funct [z y] body 
]
funct-zyx-mu: funct [body [block!]] [
	funct [z y x] body 
]
funct-zyxw-mu: funct [body [block!]] [
	funct [z y x w] body 
]

func-a-mu: func [body [block!]] [
	func [a] body
]
func-ab-mu: func [body [block!]] [
	func [a b] body
]
func-abc-mu: func [body [block!]] [
	func [a b c] body
]
func-abcd-mu: func [body [block!]] [
	func [a b c d] body
]

func-z-mu: func [body [block!]] [
	func [z] body
]
func-zy-mu: func [body [block!]] [
	func [z y] body
]
func-zyx-mu: func [body [block!]] [
	func [z y x] body
]
func-zyxw-mu: func [body [block!]] [
	func [z y x w] body
]

does-funct-mu: func [body [block!]] [
	funct [] body
]


quoth-mu: funct [
	'arg
] [
	switch/default type?/word :arg [
		word! [
			str: to-string arg
			either 1 == length? str [
				first str
			] [
				str
			]
		]
	] [
		throw "Unhandled type to quoth-mu"
	]
]

index?-find-mu: funct [
	{Same as index? find, but returns 0 if find returns none}
	series [series! gob! port! bitset! typeset! object! none!]
	value [any-type!]
] [
	pos: find series value
	either none? pos [
		0
	] [
		index? pos
	]
]

increment-mu: func ['word-or-path] [
	either path? word-or-path [
		old: get word-or-path
		set word-or-path 1 + old
		old
	] [
		++ :word-or-path
	]
]

decrement-mu: func ['word-or-path] [
	either path? word-or-path [
		old: get word-or-path
		set word-or-path 1 - old
		old
	] [
		-- :word-or-path
	]
]

readin-mu: funct [
	{Use data type after getting the quoted argument to determine input coercion}
	'value
] [
	switch/default type?/word get value [
		string! [prin "Input String: " set value input]
		integer! [set value to-integer ask "Input Integer: "]
		decimal! [set value to-integer ask "Input Float: "]
		block! [set value to-block ask "Input Series of Items: "]
	] [
		throw "Unhandled type to readin-mu"
	]
]

writeout-mu: funct [
	{Analogue to Rebol's print except tailored to Code Golf scenarios}
	value
] [
	; better implementation coming...
	switch/default type?/word get value [
		block! [
			foreach element value [
				print element
			]
		]
	] [
		print value
	]
]

; Don't think want to call it not-mu because we probably want a more powerful operator
; defined as ~ in order to compete with GolfScript/etc, rethink this.
inversion-mu: func [
	value
] [
	switch/default type?/word get value [
		string! [empty? value]
		decimal!
		integer! [
			zero? value
		]
	] [
		not value
	]
]

next-mu: funct [arg] [
	switch/default type?/word get arg [
		integer! [arg + 1] 
	] [
		next arg
	]
]

back-mu: funct [arg] [
	switch/default type?/word get arg [
		integer! [arg - 1] 
	] [
		back arg
	]
]

swap-mu: funct [
	"Swap contents of variables."
	a [word! series! gob!] b [word! series! gob!]
][
	if not equal? type? a type? b [
		throw "swap-mu must be used with common types"
	]
	either word? a [
		x: get a  
		set a get b	 
		set b x
	] [
		swap a b
	]
]

div-mu: funct [value1 value2] [
	to-integer divide value1 value2
]

add-mu: funct [value1 value2] [
	switch/default type?/word get value1 [
		block! [
			result: copy value1
			while [(not tail? value1) and (not tail? value2)] [
				change result add-mu first result first value2
				++ result
				++ value2
			]
			head result
		] 
	] [
		add value1 value2
	]
]

subtract-mu: funct [value1 value2] [
	switch/default type?/word get value1 [
		block! [
			result: copy value1
			while [(not tail? value1) and (not tail? value2)] [
				change result subtract-mu first result first value2
				++ result
				++ value2
			]
			head result
		] 
	] [
		subtract value1 value2
	]
]

negate-mu: funct [value] [
	switch/default type?/word get value [
		block! [
			result: copy value
			while [not tail? value] [
				change result negate-mu first value
				++ result
				++ value
			]
			head result
		] 
	] [
		negate value
	]
]
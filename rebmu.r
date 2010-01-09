REBOL [
	Title: "Rebmu Dialect"
	Description: {Rebol dialect designed for participating in "Code Golf" challenges}
	
	Author: "Hostile Fork"
	Home: http://hostilefork.com/rebmu/
	License: mit
	
	Date: 10-Jan-2010
	Version: 0.1.0
	
	; Header conventions: http://www.rebol.org/one-click-submission-help.r
	File: %rebmu.r
	Type: dialect
	Level: advanced
	
	Usage: { The Rebmu language is a dialect of Rebol which uses some unusual tricks to
	achieve smaller character counts in source code.  The goal is to make it easier to
	participate in programming challenges which attempt to achieve a given task in as few
	characters as possible.
	
	One of the main ways this is achieved is to use alternations of uppercase and lowercase
	letters to compress words in the source.  This is central to the Rebmu concept of
	"mushing" and "unmushing":

		>> unmush [abcDEFghi]
		== [abc def ghi]

	The choice to start a sequence of alternations with an uppercase letter is used as a special
	indicator of wishing the first element in the sequence to be interpreted as a set-word:
	
		>> unmush [ABCdefGHI]
		== [abc: def ghi]
	
	This applies to elements of paths as well.  Each path break presents an opportunity for
	a new alternation sequence, hence a set-word split:
	
		>> unmush [ABCdef/GHI]    
		== [abc: def/ghi:]

		>> unmush [ABCdef/ghi]
		== [abc: def/ghi]

	An exception to this rule are literal words, where since you cannot make a literal
	set-word in source the purpose is to allow you to indicate whether the *next* word
	should be a set-word.  Choosing lowercase for the lit word will mean the next word
	is a set-word, while uppercase means it will not be:
	
		>> unmush [abc'DEFghi]
		== [abc 'def ghi]

		>> unmush [abc'defGHI] 
		== [abc 'def ghi:]
		
	Despite being a little bit "silly" (as Code Golf is sort of silly), there is
	a serious side to the design.  Rebmu is a genuine dialect... meaning that it
	uses the Rebol parser and does not a custom string format.  Also, despite several
	shorthands defined for common Rebol operations (even as far as I for IF) the
	functions are true to their Rebol bretheren for all inputs that Rebol accepts.
	Hence one does not have to re-learn the meaning of such constructs to use
	Rebol in its unadulterated form!
	
	Rebmu programs get their own execution context.  They will unmush their input,
	set up the environment of abbreviated routines, and run the code:
	
		>> rebmu [p"Hello World"]
		Hello World
	    
	You can also pass in named arguments via a block:
	
		>> rebmu/args [pMpN] [m: "Hello" n: "World"]
		Hello
		World
		
	If you want to run your Rebmu program and let it set some values in its environment, such
	as defining functions you might want to call, you can also use the /inject refinement to
	run some code after the program has run but before the environment is disposed.
	
	For instance, the following example uses a shorthand format for defining a function that 
	triples a number:
	
		>> rebmu [Tf'x[x*3]]
	
	But defining the function isn't enough to call it, so if you had wanted to do that you
	could have said:
	
		>> rebmu/inject [Tf'x[x*3]] [pT10]
		30
		
	The injected code is just shorthand for [p t 10], where p is equal to print.
	}
	
    History: [
        0.1.0 [10-Jan-2010 {Sketchy prototype written to cover only the
        Roman Numeral example I worked through when coming up with the
        idea.  So very incomplete, more a proof of concept.} "Fork"]
    ]
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

upper: charset [#"A" - #"Z"]
lower: charset [#"a" - #"z"]
digit: charset [#"0" - #"9" #"."]
slashlike: charset [#"/" #":" #"?" #"!"]
apostrophelike: charset [#"'"]

type-of-char: func [c [char!]] [
	if upper/(c) [
		return 'upper
	]
	if lower/(c) [
		return 'lower
	]
	if digit/(c) [
		return 'digit
	]
	if slashlike/(c) [
		; no spacing but separates
		return 'slashlike
	]
	if apostrophelike/(c) [
		; space before if not at start
		return 'apostrophelike
	]
	; space before and after
	return 'symbol
]

; Simplistic routine, open to improvements.  Use PARSE dialect instead?
unmush: funct [value /deep] [
	if (any-word? :value) or (any-path? :value) [
		pos: str: mold :value
		thisType: type-of-char first pos
	
		thisIsSetWord: 'upper = thisType
		nextCanSetWord: ('apostrophelike = thisType) or ('symbol = thisType)
		while [not tail? next pos] [
			thisType: type-of-char first pos
			nextType: type-of-char first next pos
	
			; Helps w/debugging if something goes wrong...
			comment [	
				print [
					"this:" first pos "next:" first next pos
					"thisType:" to-string thisType "nextType:" to-string nextType 
					"thisIsSetWord:" thisIsSetWord "nextCanSetWord:" nextCanSetWord
				]
			]
	
			switch/default thisType [
				slashlike [
					thisIsSetWord: 'upper = nextType
					nextCanSetWord: false
				]
				apostrophelike [
					thisIsSetWord: false
					nextCanSetWord: 'upper <> nextType
				]
				symbol [
					thisIsSetWord: upper = nextType
					nextCanSetWord: false
					pos: insert pos space
					if 'symbol = thisType [
						pos: insert next pos space
					]
				]
			] [
				if (nextType <> 'slashlike) and (thisType <> nextType) [
					if ('digit = thisType) or ('symbol = thisType) [
						nextCanSetWord: true
					]
					if thisIsSetWord [
						pos: back insert next pos ":"
						thisIsSetWord: false
						nextCanSetWord: false
					]
					if nextCanSetWord [
						thisIsSetWord: 'upper = nextType
						nextCanSetWord: false
					]
					pos: back insert next pos space
				]
			]
			pos: next pos
		]
		if thisIsSetWord [
			pos: back insert next pos ":"
		]
		return load lowercase str
	] 
	
	if any-block? :value [
		result: make type? :value copy []
		while [not tail? :value] [
			elem: first+ value
			either (any-block? :elem) and (not any-path? :elem) [
				append/only result either deep [unmush/deep :elem] [:elem]
			] [
				append result unmush :elem
			]
		]
		return result
	]
	
	return :value
]

rebmu-command-defaults: [
	~: :inversion-mu
	
	IF: :if-mu
	EI: :either-mu
	EL: :either-lesser?-mu

	FN: :funct-mu

	FE: :foreach
	WH: :while
	CN: :continue
	CO: :compose
	CY: :copy
	
	;CP **copy/part**
	
	TW: :to-word-mu
	TS: :to-string-mu
	
	SE: :select
	AL: :also
	
	PR: :print
	RI: :readin-mu
	
	DR: :rebmu ; "Do Rebmu"
]

rebmu-single-defaults: [
	; shorthands for the most common control structures / functions
	i: :IF
	e: :EI
	w: :WH
	f: :FN
	p: :PR
	r: :RI
	d: :DR ; maybe unnecessary
	
	; decimal! values starting at 0.0 (common mathematical variables)
	x: y: z: 0.0
	
	; integer! values starting at zero (usually integer indexes, excluding i)
	n: j: k: 0
	
	; string! values starting at empty (string, message, text)
	s: m: t: ""
]

rebmu: func [
	{"Visit http://hostilefork.com/rebmu/}
	code [any-block! string!] "The Rebmu or Rebol code"
	/args arg [block! string!] 
	"named arguments ([a: 10 b: 20], etc) to pass to the script.  Rebmu format ok"
	/stats "print out statistical information"
	/debug "output debug information"
	/env "return the runnable object plus environment, but don't execute main function"
	/inject injection [block! string!] "run some test code in the environment after main function"
	/local result elem obj
] [
	either string? code [
		if stats [
			print ["Original Rebmu string was:" length? code "characters."]
		]

		code: load code
	] [
		if stats [
			print ["NOTE: Pass in Rebmu as string, not a block, to get official character count."]
		]
	]
	
	if not block? code [
		code: to-block code
	]
	
	if stats [
		print ["Rebmu as mushed Rebol block molds to:" length? mold/only code "characters."]
	]

	code: unmush/deep code
	
	if stats [
		print ["Unmushed Rebmu molds to:" length? mold/only code "characters."]
	]

	if debug [
		print ["Executing: " mold code]
	]
	
	either inject [
		if string? injection [injection: load injection]
		if not block? injection [
			code: to-block injection
		]
		injection: unmush/deep injection
	] [
		injection: copy []
	]
	
	either args [
		if string? arg [args: load args]
		if not block? args [
			arg: to-block arg
		]
		args: unmush/deep arg
	] [
		arg: copy []
	]
	
	obj: object compose/deep [
		(rebmu-command-defaults)
		(rebmu-single-defaults)
		(arg) 
		main: func [] [(unmush/deep code)]
		injection: func [] [(injection)]
	] 
	either env [
		return obj 
	] [
		return also (do get in obj 'main) (do get in obj 'injection)
	]
]

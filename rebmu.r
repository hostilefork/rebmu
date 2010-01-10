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

; Load the library of xxx-mu functions
do %mulibrary.r

; Table of single-character length instructions and values in Rebmu
; (It is common for user code to redefine these if the defaults are unused)
rebmu-single-defaults: [
	~: :inversion-mu
	|: :reduce
	.: none ; what should dot be?
	
	; ^ is copy because it breaks symbols; a^b becomes a^ b but A^b bcomes a: ^ b
	; This means that it is verbose to reset the a^ type symbols due to forcing a space
	^: :CY 
	
	a: copy [] ; "array"
	b: to-char 0 ; "byte"
	c: #"A" ; "char"
	d: #"0" ; "digit"
	e: :EI ; "either"
	f: :FN ; "function"
	g: copy [] ; "group"
	h: :helpful-mu ; "helpful" constant declaration tool
	i: :IF ; "if"
	j: 0
	k: 0
	l: :LO ; "loop"
	m: copy "" ; "message"
	n: 1
	o: :OR ; "or"
	p: :PO ; "poke"
	q: :quoter-mu ; "quoter" e.g. qAB => "AB" and qA => #"A"
	r: :RI ; "readin"
	s: copy "" ; "string"
	t: :TO ; note that to can use example types, e.g. t "foo" 10 is "10"!
	u: :UT ; "until"
	v: copy [] ; "vector"
	w: :WO ; "writeout"
	; decimal! values starting at 0.0 (common mathematical variables)
	x: 0.0
	y: 1.0 
	z: -1.0
]

; Table of double-character length commands in Rebmu
; (It is not recommended to overwrite these definitions in your program, though you can)
rebmu-double-defaults: [
	w!: word!
	i!: integer!
	s!: string!
	b!: block!
	p!: paren!
	d!: decimal!
	l!: logic!
	n!: none!
	
	w?: :word?
	i?: :integer?
	s?: :string?
	b?: :block?
	p?: :paren?
	d?: :decimal?
	l?: logic?
	n?: none?

	IF: :if-mu ; use wrap and do [/else e]
	EI: :either-mu
	EL: :either-lesser?-mu
	IL: :if-lesser?-mu
	IG: :if-greater?-mu

	FN: :funct-mu ; use wrap and do [/with w]?

	FE: :foreach
	LO: :loop
	WH: :while
	CN: :continue
	UT: :until
	RT: :repeat
	
	PO: :poke	
	AP: :append
	AO: rebmu-wrap 'append/only [] ; very useful
	IN: :insert
	TK: :take
	
	CO: rebmu-wrap 'compose/deep [] ; default to deep composition
	
	CY: rebmu-wrap 'copy/part/deep [] ; default to a deep copy
	CP: rebmu-wrap 'copy/part [] ; default to a deep copy
	
	RA: rebmu-wrap 'replace/all []
	
	ML: :mold
	
	TW: :to-word-mu
	TS: :to-string-mu
	TB: :to-block
	
	SE: :select
	AL: :also
	
	PR: :print
	RI: :readin-mu
	WO: :print ; will be fancier "writeout-mu"
	
	DR: :rebmu ; "Do Rebmu"
	
	RV: :reverse
	
	; Although a caret in isolation means "copy", a letter and a caret means "factory"
	a^: :array
	i^: :make-integer-mu
	m^: :make-matrix-mu
	s^: :make-string-mu
	
	; SP: :space ; Rebol already defines this...
]

upper: charset [#"A" - #"Z"]
lower: charset [#"a" - #"z"]
digit: charset [#"0" - #"9" #"."]
slashlike: charset [#"/" #":"]
apostrophelike: charset [#"'"]
exclamationlike: charset [#"!" #"?" #"^^"]

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
	if exclamationlike/(c) [
		; space afterwards but not before (we use ~ for not)
		return 'exclamationlike
	]
	; space before and after
	return 'symbol
]

; Simplistic routine, open to improvements.  Use PARSE dialect instead?
; IF unmush returns a block! (and you didn't pass in a block!) then it is a sequence
; There may be a better convention
unmush: funct [value /deep] [
	if (any-word? :value) or (any-path? :value) [
		pos: str: mold :value
		thisType: type-of-char first pos
	
		mergedSymbol: false
		thisIsSetWord: 'upper = thisType
		nextCanSetWord: found? find [apostrophelike symbol exclamationlike] thisType
		while [not tail? next pos] [
			nextType: if not tail? next pos [type-of-char first next pos]
			
			comment [	
				print [
					"this:" first pos "next:" first next pos
					"thisType:" to-string thisType "nextType:" to-string nextType 
					"thisIsSetWord:" thisIsSetWord "nextCanSetWord:" nextCanSetWord
					"str:" str
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
				exclamationlike
				symbol [
					either (first pos) == (first next pos) [
						mergedSymbol: true
					] [
						if ('symbol = thisType) or thisIsSetWord [
							if thisIsSetWord [
								pos: insert pos ":"
							]
							either mergedSymbol [
								mergedSymbol: false
							] [
								pos: insert pos space
							]
						]
						pos: back insert next pos space
						thisIsSetWord: 'upper = nextType
						nextCanSetWord: false
					]
				]
			] [
				either ('digit = thisType) and found? find [#"x" #"X"] first next pos [
					; need special handling if it's an x because of pairs
					; want to support mushings like a10x20 as [a 10x20] not [a 10 x 20]
					; for the moment lie and say its a digit
					nextType: 'digit	
				] [
					if (thisType <> nextType) and none? find [slashlike exclamationlike] nextType [
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
			]
			pos: next pos
			thisType: nextType
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
			unmushed: either deep [unmush/deep :elem] [unmush :elem]
			either (block? unmushed) and (not block? :elem) [
				append result unmushed
			] [
				append/only result unmushed
			]
		]
		return result
	]
	
	return :value
]

; The point of Rebmu is that programmers should be able to read and modify without using
; a compilation tool.  But for completeness, here is a mushing function.
; **UNDER CONSTRUCTION**
mush: funct [value /mixed /deep] [
	print "WARNING: Mushing is a work in progress, implementation incomplete."
	if any-block? value [
		result: make type? :value copy []
		isUppercase: none
		current: none
		foreach elem value [
			switch/default type?/word :elem [
				word! [
					either current [
						isUppercase: not isUppercase
						either isUppercase [
							append current uppercase to-string elem
						] [
							append current lowercase to-string elem
						]
					] [
						current: lowercase to-string elem
						isUppercase: false
					]
				]
				set-word! [
					either current [
						append result to-word current
						current: none
						append result elem
					] [
						current: uppercase to-string-mu elem ; spelling? behavior
						isUppercase: true
					]
				]
			] [
				if current [
					append result to-word current
					current: none
				]
				append/only result :elem
			]
		]
	]
	if current [
		append result to-word current
		current: none
	]
	result
]

; A rebmu wrapper lets you wrap a function or a refined version of a function
rebmu-wrap: funct [arg [word! path!] refinemap [block!]] [
	either word? arg [
		; need to use refinemap!
		:arg
	] [
		; need to write generalization of spec capture with reflect, e.g.
		; spec: reflect :arg 'spec 
		; just testing concept for the moment with a couple of cases though
		; so writing by hand
		switch arg [
			replace/all [
				func [target search value] [
					replace/all target search value
				]
			]
			compose/deep [
				func [value] [
					compose/deep value
				]
			] 
			copy/part/deep [
				func [value length] [
					copy/part/deep value length
				]
			]
			copy/part [
				func [value length] [
					copy/part value length
				]
			]
			append/only [
				func [series value] [
					append/only series value
				]
			]
		]
	]
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
		(rebmu-double-defaults) ; Generally, don't overwrite these in your Rebmu code
		(rebmu-single-defaults) ; Overwriting is okay here
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
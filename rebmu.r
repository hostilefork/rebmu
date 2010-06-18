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
	uses the Rebol data format and thus relegates most parsing--such as parentheses
	and block matches.  This means that there's no string-oriented trickery taking
	advantage of illegal source token sequences in Rebol (like 1FOO, A:B, A$B...)
	
	Also, Rebmu is a superset of Rebol, so any Rebol code should be able to be used
	safely.  That's because despite several shorthands defined for common Rebol operations 
	(even as far as I for IF) the functions are true to their Rebol bretheren across 
	all inputs that Rebol accepts.  [Current exceptions to this are q and ?]
	
	Rebmu programs get their own execution context.  They will unmush their input,
	set up the environment of abbreviated routines, and run the code:
	
		>> rebmu [w"Hello World"]
		Hello World
	    
	You can also pass in named arguments via a block:
	
		>> rebmu/args [wSwM] [s: "Hello" m: "World"]
		Hello
		World
		
	Or you can pass in a block which does not begin with a set-word and that block will
	appear in the execution context as the variable a:
	
		>> rebmu/args [wA] [1 2 3]
		1 2 3
	
	You can run your Rebmu program and let it set some values in its environment, such
	as defining functions you might want to call.  Using the /inject refinement you can
	run some code after the program has executed but before the environment is disposed.
	
	For instance, the following example uses a shorthand format for defining a function that 
	triples a number and saving it in t:
	
		>> rebmu [T|[a*3]]
	
	But defining the function isn't enough to call it, so if you had wanted to do that you
	could have said:
	
		>> rebmu/inject [T|[a*3]] [wT10]
		30
		
	The injected code is just shorthand for [w t 10], where w is writeout-mu, a variation of
	Rebol's print.
	}
	
    History: [
        0.1.0 [10-Jan-2010 {Sketchy prototype written to cover only the
        Roman Numeral example I worked through when coming up with the
        idea.  So very incomplete, more a proof of concept.} "Fork"]
    ]
]

; Load the library of xxx-mu functions
do %mulibrary.r

; Load the library implementing mush/unmush
do %mushing.r

rebmu-context: [
	;-------------------------------------------------------------------------------------
	; WHAT REBOL DEFINES BY DEFAULT IN THE TWO-CHARACTER SPACE
	;-------------------------------------------------------------------------------------	
	
	; Very Reasonable Use of English Words
	
	; TO 	to conversion
	; OR	or operator
	; IN	word or block in the object's context
	; IF	conditional if
	; DO	evaluates a block, file, url, function word
	; AT	returns the series at the specified index
	; NO	logic false
	; ON	logic true

	; Reasonable use of Symbolic Operators

	; ++ 	increment and return previous value
	; -- 	decrement and return previous value
	; ??	Debug print a word, path, block or such
	; >=	true if the first value is greater than the second
	; <>	true if the values are not equal
	; <=	true if the first value is less than the second
	; =?	true if the values are identical
	; //	remainder of first value divided by second
	; **	first number raised to the power of the second
	; !=	true if the values are not equal

	; Questionable shorthands for terms defined elsewhere. Considering how many things do
	; not have shorthands by default...what metric proved that *these four* were the
	; ideal things to abbreviate? 
	
	; SP 	alias for SPACE
	; RM	alias for DELETE
	; DP	alias for DELTA-PROFILE
	; DT	alias for DELTA-TIME

	; These are shell commands and it seems like there would be many more.  Could there
	; be a shell dialect, in which for instance issue values (#foo) could be environment
	; variables, or something like that?  It seems many other things would be nice, like
	; pushing directories or popping them, moving files from one place to another, etc.	
	
	; LS	print contents of a directory
	; CD	change directory

	; Another abbreviation that seems better to leave out
	; DS	temporary stack debug
	
	;-------------------------------------------------------------------------------------
	; DATATYPE SHORTHANDS (3 CHARS)
	; Though I considered giving the datatypes 2-character names, I decided on 3 and saving
	; the one-characters for things like index? and offset? and length?  Literal words
	; for types will probably not be showing up too often in Code Golf.
	;-------------------------------------------------------------------------------------	

	(remap-datatype 'email 'em)
	(remap-datatype 'block 'bl)
	(remap-datatype 'char 'ch)
	(remap-datatype 'decimal 'dc)
	(remap-datatype 'error 'er)
	(remap-datatype 'function 'fn)
	(remap-datatype 'get-word 'gw)
	(remap-datatype 'paren 'pn)
	(remap-datatype 'integer 'in)
	(remap-datatype 'pair 'pr)
	(remap-datatype 'closure 'cl)
	(remap-datatype 'logic 'lg) 
	(remap-datatype 'map 'mp)
	(remap-datatype 'none 'nn)
	(remap-datatype 'object 'ob)
	(remap-datatype 'path 'pa)
	(remap-datatype 'lit-word 'lw)
	(remap-datatype 'refinement 'rf)
	(remap-datatype 'string 'st)
	(remap-datatype 'time 'tm)
	(remap-datatype 'tuple 'tu)
	(remap-datatype 'file 'fi) 
	(remap-datatype 'word 'wd)
	(remap-datatype 'tag 'tg) 
	(remap-datatype 'money 'mn)
	(remap-datatype 'binary 'bi)
	
	; TODO: make these automatically along with the datatype shorthands
	TWD: :to-word-mu
	TST: :to-string-mu
	TBL: :to-block

	;-------------------------------------------------------------------------------------	
	; TYPE CONVERSION SHORTHANDS
	; These are particularly common and there aren't many commands starting with T
	; So aliasing them is useful.  May reconsider this later.
	;-------------------------------------------------------------------------------------	
	
	TW: :TWD
	TS: :TST
	TB: :TBL

	;-------------------------------------------------------------------------------------
	; CONDITIONALS
	;-------------------------------------------------------------------------------------	
	
	IF: :if-mu
	EI: :either-mu
	EL: :either-lesser?-mu
	EG: :either-greater?-mu
	EE: :either-equal?-mu
	EZ: :either-zero?-mu
	IL: :if-lesser?-mu
	IG: :if-greater?-mu
	IE: :if-equal?-mu
	IZ: :if-zero?-mu
	SW: :switch

	;-------------------------------------------------------------------------------------	
	; LOOPING CONSTRUCTS
	;-------------------------------------------------------------------------------------	

	FE: :foreach
	LO: :loop
	WH: :while-mu
	WG: :while-greater?-mu
	WL: :while-lesser?-mu
	WGE: :while-greater-or-equal?-mu
	WLE: :while-lesser-or-equal?-mu
	WE: :while-equal?-mu
	CN: :continue
	BR: :break
	UT: :until
	RT: :repeat
	FV: :forever

	;-------------------------------------------------------------------------------------	
	; DEFINING FUNCTIONS
	;-------------------------------------------------------------------------------------	

	FN: :funct
	FC: :func
	DZ: :does
	DF: :does-funct-mu
	a|: :a|funct-mu
	b|: :b|funct-mu
	c|: :c|funct-mu
	d|: :d|funct-mu
	; TODO: Write generator? 
	|a: :func|a-mu
	|b: :func|b-mu
	|c: :func|c-mu
	|d: :func|d-mu
	RN: :return
	
	;-------------------------------------------------------------------------------------
	; SERIES OPERATIONS
	;-------------------------------------------------------------------------------------	

	PO: :poke
	PC: :pick
	AP: :append
	AO: rebmu-wrap 'append/only [] ; very useful
	IN: :insert
	TK: :take
	MN: :minimum-of
	MX: :maximum-of
	RP: :repend
	SE: :select
	RV: :reverse
	RA: rebmu-wrap 'replace/all []
	HD: :head
	TL: :tail
	BK: :back-mu
	NT: :next-mu
	CH: :change
	SK: :skip
	FI: :find

	L?: :length?	
	F?: :index?-find-mu
	O?: :offset?
	I?: :index?
	T?: :tail?
	H?: :head?
	M?: :empty?
	
	FR: :first
	SC: :second
	TH: :third
	FH: :fourth
	
	; Mushing always breaks a + into its own token (unless next to another +, e.g. ++)
	; Hence we can't have F+.  FP is close...
	FP: :first+
	
	;-------------------------------------------------------------------------------------	
	; METAPROGRAMMING
	;-------------------------------------------------------------------------------------	

	CO: :compose
	COD: rebmu-wrap 'compose/deep []
	ML: :mold
	DR: :rebmu ; "Do Rebmu"
	RE: :reduce
	RJ: :rejoin
	RO: rebmu-wrap 'repend/only []

	;-------------------------------------------------------------------------------------	
	; MATH AND LOGIC OPERATIONS
	;-------------------------------------------------------------------------------------	

    AD: :add-mu
    SB: :subtract
	MP: :multiply
	DV: :div-mu
	DD: :divide
	IM: :inversion-mu
	Z?: :zero?
	MO: :mod
	E?: :equal?
	AN: :AND ; mapped to & as well
	EV?: :even?
	OD?: :odd?
	++: :increment-mu
	--: :decrement-mu
	GT?: :greater?
	GE?: :greater-or-equal?
	LT?: :lesser?
	LE?: :lesser-or-equal?
	NG?: :negative?
	SG?: :sign?
	
	;-------------------------------------------------------------------------------------	
	; INPUT/OUTPUT
	;-------------------------------------------------------------------------------------	
	
	RD: :read
	WR: :write
	PR: :print
	PN: :prin
	RI: :readin-mu
	WO: :writeout-mu
	RL: rebmu-wrap 'read/lines []
	NL: :newline
	
	;-------------------------------------------------------------------------------------	
	; CONSTRUCTION FUNCTIONS
	; Although a caret in isolation means "copy", a letter and a caret means "factory"
	;-------------------------------------------------------------------------------------	

	CY: :copy
	MK: :make
	CYD: rebmu-wrap 'copy/deep []
	CP: rebmu-wrap 'copy/part [] 
	CPD: rebmu-wrap 'copy/part/deep [] 
	a^: :array
	i^: :make-integer-mu
	m^: :make-matrix-mu
	s^: :make-string-mu
	
	;-------------------------------------------------------------------------------------		
	; MISC
	;-------------------------------------------------------------------------------------	
	
	AL: :also
	NN: :none
	HM: :helpful-mu
	NN: :none
	ST: :set
	GT: :get
	RF: :redefine-mu
	EN: :encode
	SX: :swap-mu
	
	;-------------------------------------------------------------------------------------
	; SINGLE CHARACTER DEFINITIONS
	; For the values (e.g. s the empty string) it is expected that you will overwrite them
	; during the course of your program.  It's a little less customary to redefine the
	; functions like I for IF, although you may do so if you feel the need.  They will
	; still be available in a two-character variation.
	;-------------------------------------------------------------------------------------
	
	~: :IM
	|: :DF  ; funct generator w/no parameters		
	&: :AN

	.: :RF
	?: none ; not help , but what should it be
	
	; ^ is copy because it breaks symbols; a^b becomes a^ b but A^b bcomes a: ^ b
	; This means that it is verbose to reset the a^ type symbols due to forcing a space
	^: :CY 
	
	; TODO: there is an issue where if an argument a is put into the block you can't
	; overwrite its context if you're inside something like a while block.  How
	; to resolve this?
	a: copy [] ; "array"
	b: to-char 0 ; "byte"
	c: #"A" ; "char"
	d: #"0" ; "digit"
	e: :EI ; "either"
	f: :FN ; "function"
	g: copy [] ; "group"
	h: :HM ; "helpful" constant declaration tool
	i: :IF ; "if"
	j: 0
	k: 0
	l: :LO ; "loop"
	m: copy "" ; "message"
	n: 1
	o: :OR ; "or"
	p: :PO ; "poke"
	
	; Q is tricky.  I've tried not to violate the meanings of any existing Rebol functions,
	; but it seems like a waste to have an interpreter-only function like "quit" be taking
	; up such a short symbol by default.  I feel the same way about ? being help.  This
	; is an issue I have with Rebol's default definitions -Fork
	q: :quoth-mu ; "quoth" e.g. qAB => "AB" and qA => #"A"
	
	r: :RI ; "readin"
	s: copy "" ; "string"
	t: :TO ; note that to can use example types, e.g. t "foo" 10 is "10"!
	u: :UT ; "until"
	v: copy [] ; "vector"
	w: :WO ; "writeout"
	; decimal! values starting at 0.0 (common mathematical variables)
	x: 0.0
	y: 0.0 
	z: 0.0
]

remap-datatype: func [type [word!] shorter [word!]] [
    ; we really should be binding these into the rebmu context, lazy and putting
    ; them global for expedience.
	do bind/set/new reduce [
		to-set-word rejoin [to-string shorter "!"] to-get-word rejoin [to-string type "!"]
		to-set-word rejoin [to-string shorter "?"] to-get-word rejoin [to-string type "?"]
	] bind? 'system
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
			copy/deep [
				func [value] [
					copy/deep value
				]
			]
			copy/part [
				func [value length] [
					copy/part value length
				]
			]
			copy/part/deep [
				func [value length] [
					copy/part/deep value length
				]
			]
			append/only [
				func [series value] [
					append/only series value
				]
			]
			repend/only [
				func [series value] [
					repend/only series value
				]
			]
		]
	]
]

rebmu: func [
	{Visit http://hostilefork.com/rebmu/}
	code [any-block! string!] "The Rebmu or Rebol code"
	/args arg {named Rebmu arguments [X10Y20] or implicit a: block [1"hello"2]}
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
		arg: unmush/deep arg
		if not set-word? first arg [
			; implicitly assign to a if the block doesn't start with a set-word
			arg: compose/only [a: (arg)] 
		]
	] [
		arg: copy []
	]
	
	obj: object compose/deep [
		(compose rebmu-context)
		(arg) 
		main: func [] [(code)]
		injection: func [] [(injection)]
	] 
	either env [
		return obj 
	] [
		return also (do get in obj 'main) (do get in obj 'injection)
	]
]
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
        0.2.0 [18-Jan-2010 {Language now includes
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

; Having trouble getting this to work programmatically in a way that doesn't require
; passing in the query function but uses the stem, e.g. "email" => "em" and do the
; binding.  Think it's due to bugs in R3A99.  Workaround I pass the query function in.

	(remap-datatype email! email? "em")
	(remap-datatype block! block? "bl")
	(remap-datatype char! char? "ch")
	(remap-datatype decimal! decimal? "dc")
	(remap-datatype error! error? "er")
	(remap-datatype function! error? "fn")
	(remap-datatype get-word! error? "gw")
	(remap-datatype paren! paren? "pn")
	(remap-datatype integer! integer? "in")
	(remap-datatype pair! pair? "pr")
	(remap-datatype closure! closure? "cl")
	(remap-datatype logic! logic? "lg") 
	(remap-datatype map! map? "mp")
	(remap-datatype none! none? "nn")
	(remap-datatype object! object? "ob")
	(remap-datatype path! path? "pa")
	(remap-datatype lit-word! lit-word? "lw")
	(remap-datatype refinement! refinement? "rf")
	(remap-datatype string! string? "st")
	(remap-datatype time! time? "tm")
	(remap-datatype tuple! tuple? "tu")
	(remap-datatype file! file? "fi") 
	(remap-datatype word! word? "wd")
	(remap-datatype tag! tag? "tg") 
	(remap-datatype money! money? "mn")
	(remap-datatype binary! binary? "bi")
	
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
	INE: :if-not-equal?-mu
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
	AO: rebmu-wrap 'append/only [series value] ; very useful
	IS: :insert ; IN is a keyword
	IO: rebmu-wrap 'insert/only [series value]
	IP: rebmu-wrap 'insert/part [series value length]
	IPO: rebmu-wrap 'insert/part/only [series value length]
	TK: :take
	MNO: :minimum-of
	MXO: :maximum-of
	RP: :repend
	SE: :select
	RV: :reverse
	RA: rebmu-wrap 'replace/all [target search replace]
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
	COD: rebmu-wrap 'compose/deep [value]
	ML: :mold
	DR: :rebmu ; "Do Rebmu"
	RE: :reduce
	RJ: :rejoin
	RO: rebmu-wrap 'repend/only [series value]

	;-------------------------------------------------------------------------------------	
	; MATH AND LOGIC OPERATIONS
	;-------------------------------------------------------------------------------------	

    AD: :add-mu
    SB: :subtract-mu
	MP: :multiply
	DV: :div-mu
	DD: :divide
	IM: :inversion-mu
	NG: :negate-mu
	Z?: :zero?
	MO: :mod
	E?: :equal?
	AN: :AND~ ; mapped to & as well but maybe we should use that for something else
	OO: :OR~ ; don't want to change infix default, consider this short for "ooooor...." :)
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
	Y?: :true?
	N?: func [val] [not true? val] ; can be useful
	MN: :min
	MX: :max
	
	;-------------------------------------------------------------------------------------	
	; INPUT/OUTPUT
	;-------------------------------------------------------------------------------------	
	
	RD: :read
	WR: :write
	PR: :print
	PN: :prin
	RI: :readin-mu
	WO: :writeout-mu
	RL: rebmu-wrap 'read/lines [source]
	NL: :newline

	;-------------------------------------------------------------------------------------	
	; STRINGS
	;-------------------------------------------------------------------------------------	
	TRM: :trim
	TRT: rebmu-wrap 'trim/tail [series]
	TRH: rebmu-wrap 'trim/head [series]
	TRA: rebmu-wrap 'trim/all [series]
	
	;-------------------------------------------------------------------------------------	
	; CONSTRUCTION FUNCTIONS
	; Although a caret in isolation means "copy", a letter and a caret means "factory"
	;-------------------------------------------------------------------------------------	

	CY: :copy
	MK: :make
	CYD: rebmu-wrap 'copy/deep [value]
	CP: rebmu-wrap 'copy/part [value] 
	CPD: rebmu-wrap 'copy/part/deep [value] 
	a^: :array
	ai^: rebmu-wrap 'array/initial [size value]
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
	
	; ^ is something that needs to have thought given to it
	; because it breaks symbols; a^b becomes a^ b but A^b bcomes a: ^b
	; ^foo is therefore good for construction functions which are going
	; to target an assignment but little else.  getting a ^ in isolation
	; requires situations like coming in front of a block or a string
	; literal so it might make sense to define it as something that is 
	; frequently applied to series literals.  decoding base-64 strings
	; might be an option as they are used a lot in code golf.
	^: :caret-mu
	
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

remap-datatype: func [type [datatype!] 'query [word!] shorter [string!]] [
    typename: head remove back tail to-string to-word type
;    query: bind to-word rejoin [typename "?"] bind? 'system
    shorter-type: bind/new to-word rejoin [shorter "!"] bind? 'system
    shorter-query: bind/new to-word rejoin [shorter "?"] bind? 'system
    set shorter-type type
    set shorter-query :query
]

; A rebmu wrapper lets you wrap a refinement
; need to write generalization of spec capture with reflect, e.g.
; spec: reflect :arg 'spec 
rebmu-wrap: funct [refined [path!] args [block!]] [
	func args compose [
		(refined) (args)
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
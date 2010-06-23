REBOL [
	Title: "Mushing Routines"
	Description: {Routines implementing the Rebmu concept of "mushing".	 Mushed Rebol still
	passes the parser but uses particular sequences of upper and lower case terms and
	symbol processing within words to achieve an approximately 40% reduction in whitespace.

	Both an unmush and mush routine (stub) are provided.  However, it is important to bear in 
	mind that the point of Rebmu is to provide a language which despite achieving a low character
	count is still fairly feasible to code in without using an assistive compilation step.
	While distributing unmushed code with comments and then mushing it might be a good
	technique, it defeats the point of proving that you can actually code in Rebmu without
	resorting to that.
	}
]

upper: charset [#"A" - #"Z"]
lower: charset [#"a" - #"z"]
digit: charset [#"0" - #"9" #"."]
separatorsymbol: charset [#"/" #":"]
headsymbol: charset [#"'"]
tailsymbol: charset [#"!" #"?" #"^^" #"|" #"+" #"-" #"~" #"&" #"="]
isolatedsymbol: charset [] ; used to use for +, -, etc but were wasteful of symbols A+, B-, etc.
; (so use AD, SB instead!)
; are - and + too foundational in functions like to-char that it should be a letter?

type-of-char: func [c [none! char!]] [
	if none? c [
		return none
	]
	if upper/(c) [
		return 'upper
	]
	if lower/(c) [
		return 'lower
	]
	if digit/(c) [
		return 'digit
	]
	if separatorsymbol/(c) [
		; no spacing but separates
		return 'separatorsymbol
	]
	if headsymbol/(c) [
		; space before if not at start
		return 'headsymbol
	]
	if tailsymbol/(c) [
		; space afterwards but not before (we use ~ for not)
		return 'tailsymbol
	]
	if isolatedsymbol/(c) [
		; space before and after unless there's a run of identical ones
		return 'isolatedsymbol
	]
	; caseless things are neither upper nor lowercase, they stay stuck
	; with whatever is going; so most unicode characters fall into this
	; category.
	return 'caseless
]

; Simplistic routine, open to improvements.	 Use PARSE dialect instead?
; IF unmush returns a block! (and you didn't pass in a block!) then it is a sequence
; There may be a better convention
unmush: funct [value /deep] [
	case [
		(any-word? :value) or (any-path? :value) [
			pos: str: mold :value
			thisType: type-of-char first pos
		
			mergedSymbol: false
			thisIsSetWord: 'upper = thisType
			nextCanSetWord: found? find [headsymbol symbol tailsymbol] thisType
			lowerCaseRun: 'upper <> thisType
			while [nextType: type-of-char first next pos] [
				comment [
					print [
						"this:" first pos "next:" first next pos
						"thisType:" to-string thisType "nextType:" to-string nextType 
						"thisIsSetWord:" thisIsSetWord "nextCanSetWord:" nextCanSetWord
						"str:" str
					]
				]
		
				switch/default thisType [
					separatorsymbol [
						thisIsSetWord: 'upper = nextType
						nextCanSetWord: false
					]
					headsymbol [
						thisIsSetWord: false
						nextCanSetWord: 'upper <> nextType
					]
					tailsymbol [
						nextPos: pos
						while ['tailsymbol == nextType: type-of-char first nextPos] [
							nextPos: next nextPos
						]

						either (lowerCaseRun and equal? nextType 'lower) or 
							((not lowerCaseRun) and equal? nextType 'upper) [
							; if there's no case change, it's one token [a+b], that's
							; important because Rebol has functions with + and - in their
							; names and it would cause incompatibilities to break those
							; symbols if there were no case changes
							; CONTINUE AND LET THE LETTER DECIDE
						] [
							if thisIsSetWord [
								pos: insert pos ": "
								nextPos: next next nextPos ; compensate for two-char insertion
								lowerCaseRun: true
							] 
							
							; sequences like a+B turn into [a+ b]
							; but if there's more than one tailsymbol (i.e. a++B, a+-+B)
							; you instead get [a ++ b], [a +-+ b]
							either nextPos = next pos [
								; Break symbol on the right only
								pos: back insert nextPos space
								thisIsSetWord: false
							] [
								; Break symbol on the left and on the right
								insert pos space
								; We have to advance nextPos to compensate for the insertion
								pos: back insert next nextPos space
							]
							 
							thisIsSetWord: false
							nextCanSetWord: false
						]
					]
					isolatedsymbol [
						either (first pos) == (first next pos) [
							mergedSymbol: true
						] [
							if thisIsSetWord [
								pos: insert pos ":"
								either mergedSymbol [
									mergedSymbol: false
								] [
									pos: insert pos space
								]
								lowerCaseRun: true
							]
							pos: back insert next pos space
							thisIsSetWord: 'upper = nextType
							nextCanSetWord: false
						]
					]
				] [
					lowerCaseRun: 'upper <> thisType
					either ('digit = thisType) and found? find [#"x" #"X"] first next pos [
						; need special handling if it's an x because of pairs
						; want to support mushings like a10x20 as [a 10x20] not [a 10 x 20]
						; for the moment lie and say its a digit
						nextType: 'digit	
					] [
						if (thisType <> nextType) and none? find [separatorsymbol tailsymbol] nextType [
							if ('digit = thisType) or ('isolatedsymbol = thisType) [
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
				either thisType = 'tailsymbol [
					pos: insert pos ": "
				] [
					pos: back insert next pos ":"
				]
			]
			load lowercase str
		] 
	
		any-block? :value [
			result: make type? :value copy []
			while [not tail? :value] [
				elem: first+ value
				unmushed: either deep [unmush/deep :elem] [unmush :elem]
				either (block? :unmushed) and (not block? :elem) [
					append result :unmushed
				] [
					append/only result :unmushed
				]
			]
			result
		]
		
		true [
			:value
		]
	]
]

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
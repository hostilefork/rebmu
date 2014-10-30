Rebol [
    Title: {Rebol/Red proposal incubator}

    Description: {
        These are not in the MU-library because they are not Rebmu specific
        tricks, rather things that could have a general purpose in Rebol
        and/or have been proposed but not fully standardized.
    }
]


; The COMBINE dialect is intended to assist with the common task of creating
; a merged string series out of component Rebol values.  Its
; goal is to be friendlier than REJOIN, and to hopefully become the
; behavior backing PRINT.
;
; Currently in a proposal period, and there are questions about whether the
; same dialect can be meaningful for blocks or not.
;
; http://blog.hostilefork.com/combine-alternative-rebol-red-rejoin/ 
;
combine: func [
    block [block!]
    /with "Add delimiter between values (will be COMBINEd if a block)"
        delimiter [block! any-string! char! any-function!]
    /into
        out [any-string!]
    /local
        needs-delimiter pre-delimit value temp
    ; hidden way of passing depth after /local, review...
    /level depth
] [
    ;-- No good heuristic for string size yet
    unless into [
        out: make string! 10
    ]

    unless any-function? :delimiter [
        unless block? delimiter [
            delimiter: compose [(delimiter)]
        ]
        delimiter: func [depth [integer!]] compose/only/deep [
            combine (delimiter)
        ]
    ]

    unless depth [
        depth: 1
    ]

    needs-delimiter: false
    pre-delimit: does [
        either needs-delimiter [
            set/any 'temp delimiter depth
            if all [
                value? 'temp
                (not none? temp) or (block? out)
            ] [ 
                out: append out temp
            ]
        ] [
            needs-delimiter: true? with
        ]
    ]

    ;-- Do evaluation of the block until a non-none evaluation result
    ;-- is found... or the end of the input is reached.
    while [not tail? block] [
        set/any 'value do/next block 'block

        ;-- Blocks are substituted in evaluation, like the recursive nature
        ;-- of parse rules.

        case [
            unset? :value [
                ;-- Ignore unset! (precedent: any, all, compose)
            ]

            any-function? :value [
                do make error! "Evaluation in COMBINE gave function/closure"
            ]

            block? value [
                pre-delimit
                out: combine/with/into/level value :delimiter out depth + 1
            ]

            ; This is an idea that was not met with much enthusiasm, which was
            ; to allow COMBINE ['X] to mean the same as COMBINE [MOLD X]
            ;any [
            ;    word? value
            ;    path? value
            ;] [
            ;    pre-delimit ;-- overwrites temp!
            ;    temp: get value
            ;    out: append out (mold :temp)
            ;]

            ; It's a controversial question as to whether or not a literal
            ; word should mold out as its spelling.  The idea that words
            ; don't cover the full spectrum of strings is something that
            ; got stuck in my head that words shouldn't "leak".  So I was
            ; very surprised to see that they did, and if you used a word
            ; selection out of a file path as FILE/SOME-WORD then it would
            ; append the spelling of SOME-WORD to the file.  That turned
            ; the idea on its head to where leakage of words might be okay,
            ; along with the idea of liberalizing what strings could be 
            ; used as the spelling of words to anything via construction
            ; syntax.  So pursuant to that I'm trying to ease up so that
            ; if evaluation winds up with a word value, e.g. held in 
            ; a variable or returned from a function then that is 
            ; printable.  But set words, get words, and paths are too
            ; "alive" and should be molded.  Hmmm.  FORM is a better
            ; word than MOLD.  If TO-STRING could take the responsibility
            ; of FORM then MOLD could take FORM.  Enough tangent.

            any [
                word? value
            ] [
                pre-delimit ;-- overwrites temp!
                out: append out (to-string value)
            ]

            ; Another idea that seemed good at first but later came back not
            ; seeming so coherent...use of an otherwise dead type to 
            ; suppress delimiting.  So:
            ;
            ;     >> combine/with ["A" "B" /+ "C"] "."
            ;     == "A.BC"
            ;  
            ; This was particularly ugly when the pieces being joined were
            ; file paths and had slashes in them.  But the concept may be  
            ; worth implementing another way so that the delimiter-generating
            ; function can have a first crack at processing values?

            ;refinement? value [
            ;    case [
            ;        value = /+ [
            ;            needs-delimiter: false
            ;        ]
            ;
            ;        true [
            ;            do make error! "COMBINE refinement other than /+ used"
            ;        ]
            ;    ]
            ;]

            any-block? value [
                ;-- all other block types as *results* of evaluations throw
                ;-- errors for the moment.  (It's legal to use PAREN! in the
                ;-- COMBINE, but a function invocation that returns a PAREN!
                ;-- will not recursively iterate the way BLOCK! does) 
                do make error! "Evaluation in COMBINE gave non-block! or path! block"
            ]

            any-word? value [
                ;-- currently we throw errors on words if that's what an
                ;-- evaluation produces.  Theoretically these could be
                ;-- given behaviors in the dialect, but the potential for
                ;-- bugs probably outweighs the value (of converting implicitly
                ;-- to a string or trying to run an evaluation of a non-block)
                do make error! "Evaluation in COMBINE gave symbolic word"
            ]

            none? value [
                ;-- Skip all nones
            ]

            true [
                pre-delimit
                out: append out (form :value)
            ]
        ]
    ]
    either into [out] [head out]
]


; Just make FOR equal to repeat for now, but we want a dialect
for: :repeat


if 1 = length? words-of :until [
    old-while: :while
    old-until: :until
]

; Reimagination of until and while
; http://curecode.org/rebol3/ticket.rsp?id=2163
while: func [
    cond-block [block!]
    body-block [block!]
    /after
] [
    if after [do body-block]
    old-while cond-block body-block
]

until: func [
    cond-block [block!]
    body-block [block!]
    /after
] [
    if after [do body-block]
    old-while [not do cond-block] body-block
]


; updated PRINT to use COMBINE
print: func [value [any-type!] /only] [
    case [
        unset? :value [
            ;-- ignore it...
        ] 

        block? value [
            prin combine/with value func [depth] [space]
        ]

        string? value [
            prin value
        ]

        path? value [
            prin mold get value
        ]

        series? value [
            do make error! "Cannot print non-block!/string! series directly, use MOLD or lit-word"
        ]
        
        word? value [
            prin mold get value
        ]

        any-word? value [
            do make error! "Cannot print non-word! words directly, use MOLD"
        ]

        any-function? value [
            do make error! "Cannot print functions directly, use MOLD or lit-word"
        ]

        object? value [
            do make error! "Cannot print objects directly, use MOLD or lit-word"
        ]

        true [
            prin form value
        ]
    ]

    unless only [
        prin newline
    ]

    exit
]


digit: func [
    /binary
    /hex
    /uppercase
    /lowercase
] [
    if all [uppercase lowercase] [
        do make error! "Can't use uppercase and lowercase refinements together"
    ]

    if binary [
        if hex [
            do make error! "Can't use /binary and /hex refinements together"
        ]
        return charset [#"0" #"1"]
    ]

    if hex [
        return case [
            uppercase [
                charset [#"0" - #"9" #"A" - #"F"]
            ]
            lowercase [
                charset [#"0" - #"9" #"a" - #"f"]
            ]
            true [
                charset [#"0" - #"9" #"a" - #"f" #"A" - #"F"]
            ]
        ]
    ]

    return charset [#"0" - #"9"]
]


letter: func [
    /uppercase
    /lowercase
    /latin
] [
    if all [uppercase lowercase] [
        do make error! "Can't use uppercase and lowercase refinements together"
    ]

    unless latin [
        do make error! "/latin refinement required by letter, no unicode yet"
    ]

    if uppercase [
        return charset [#"A" - #"Z"]
    ]

    if lowercase [
        return charset [#"a" - #"z"]
    ]

    ; Default should work with unicode.
    return charset [#"A" - #"Z" #"a" - #"z"]
]


whitespace: func [
] [
    return charset [tab space newline cr]
]


; http://curecode.org/rebol3/ticket.rsp
wrap: func [
    "Evaluates a block, wrapping all set-words as locals."
    body [block!] "Block to evaluate"
] [
    do bind/copy/set body make object! 0
]

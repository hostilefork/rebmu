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
; goal is to be friendlier than REJOIN.
;
; Currently in a proposal period, and there are questions about whether the
; same dialect can.
;
; http://curecode.org/rebol3/ticket.rsp?id=2142&cursor=1 
;
combine: func [
    block [block!]
    /with "Add delimiter between values (will be COMBINEd if a block)"
        delimiter [block! any-string! char! any-function!]
    /into
        out [any-string!]
    /local
        needs-delimiter pre-delimit value
] [
    ;-- No good heuristic for string size yet
    unless into [
        out: make string! 10
    ]

    if block? delimiter [
        delimiter: combine delimiter
    ]

    needs-delimiter: false
    pre-delimit: does [
        either needs-delimiter [
            out: append out delimiter
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
                out: combine/into value out
            ]

            any-block? value [
                ;-- all other block types as *results* of evaluations throw
                ;-- errors for the moment.  (It's legal to use PAREN! in the
                ;-- COMBINE, but a function invocation that returns a PAREN!
                ;-- will not recursively iterate the way BLOCK! does) 
                do make error! "Evaluation in COMBINE gave non-block! block"
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


; A single-arity while (analogue of UNTIL but where the condition is
; checked before the rest of the code is executed).  A far better
; option than the previous WHILE-MU, hopefully to be blessed by the
; core as useful in its own right.  See CureCode:
;
; http://curecode.org/rebol3/ticket.rsp?id=2146&cursor=1
;
whilst: func [cond+code [block!] /local code] [
    while [do/next cond+code 'code] [
        do code
    ]
]

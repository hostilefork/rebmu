Rebol [
    Title: "The Mu Rebol Library"
    Type: module
    Name: MuLib

    Description: {
        This is a library generally designed to be used with abbreviated
        symbols in Rebmu.  While there is a fuzzy line between "library" and
        "language", the intention is not to achieve a low symbol count at the
        cost of creating something that is incompatible with Rebol.

        In Rebmu's development it has shifted away from "weird" single-
        character tools designed specifically for code golf, and is focusing
        more on balance and readability of good practices in Rebol and Red.
        Items are being removed from the MU-library and turned into proper
        proposals for the languages themselves when the function is genuinely
        useful to have around.
    }
]


; FN aims to be a fully compatible superset of Rebol's FUNCTION.  This means
; the spec and body parameters must be evaluative.
;
; !!! Technically, once those arguments are evaluated, it could do something
; with types Rebol considers invalid.  INTEGER! would be a good example,
; perhaps just create a function with that many args.
;
; !!! Should FUNCTION-MU be revised e.g. to make all "normal" parameters be
; meta and then pass through isotopes (non ~null~ ones, anyway?)  Or might that
; be disruptive enough to the interface to be something different (e.g. FX?)
;
export function-mu: adapt :function [
    body: compose [
        let rt: :return  ; can't `R: RETURN` globally, alias per function
        let r: :rt
        (as group! body)
    ]
]

; FUNQTION: Dialecting The Function Definition Process
;
; https://forum.rebol.info/t/1796
;
; As an example: a naming pattern of a letter and a number could indicate to
; make 3 args with names starting at that letter:
;
;     fqR3[...] => fq r3 [...] -> fn [r s t] [...]
;
; Inspired by the mechanic of DOES, if a WORD! naming a function is found when
; it expects a body block, then that function will be implicit, e.g.
;
;     fqR2ay[r + s] => fq r2 ay [r + s] => fn [r s] [ay [r + s]]
;
export funqtion-mu: lambda [arg [<opt> any-value! <variadic>]] [
    spec: collect [
        keep switch spec [
            a [[a]]
            b [[a b]]
            c [[a b c]]
            d [[a b c d]]

            z [[z]]
            y [[z y]]
            x [[z y x]]
            w [[z y x w]]
        ]
    ]
    fn spec body
]

export if-mu: lambda [condition branch] [
    lib.if :condition
        (match [block! action!] :branch else '[:branch])
]

export either-mu: lambda [condition true-branch false-branch] [
    lib.either :condition
        (match [block! action!] :true-branch else '[:true-branch])
        (match [block! action!] :false-branch else '[:false-branch])
]

export to-text-mu: lambda [
    value
][
    either any-word? value [
        ; This code comes from spelling? from an old version of Bindology
        ; Ladislav and Fork are hoping for this to be the functionality of
        ; to-string in Rebol 3.0 for words (then this function would then be
        ; unnecessary).

        case [
            word? :value [mold :value]
            set-word? :value [head remove back tail mold :value]
            true [next mold :value]
        ]
    ][
        to-text value
    ]
]

export to-char-mu: lambda [
    value
][
    either any-word? value [
        ; This code comes from spelling? from an old version of Bindology
        ; Ladislav and HostileFork are hoping for this to be the functionality
        ; of to-string in Rebol 3.0 for words (then this function would then
        ; be unnecessary).

        case [
            word? :value [first mold :value]
            set-word? :value [first head remove back tail mold :value]
            true [first next mold :value]
        ]
    ][
        to-char value
    ]
]

export to-word-mu: lambda [value] [
    either char? value [
        to-word to-text value
    ][
        to-word value
    ]
]

export to-http-url-mu: lambda ['target [word! path! text!] /secure][
    join either secure [https://][http://] target
]

export caret-mu: lambda ['value] [
    switch type of :value [
        text! [to-text debase value]

        fail "caret-mu needs to be thought out for non-strings, see rebmu.reb"
    ]
]

export redefine-mu: lambda ['dest 'source] [
    set :dest get :source
]

export make-matrix-mu: lambda [columns value rows] [
    result: copy []
    loop rows [
        append result array/initial columns value
    ]
    result
]

export make-string-initial-mu: lambda [length value] [
    result: copy ""
    loop length [
        append result value
    ]
    result
]

; if a pair, then the first digit is the digit
export make-integer-mu: lambda [value] [
    switch type of :value [
        pair! [to-integer first value * (10 ** second value)]
        integer! [to-integer 10 ** value]

        fail "Unhandled type to make-integer-mu"
    ]
]

export quoth-mu: lambda [
    'arg
][
    switch type of :arg [
        word! [
            str: to-text arg
            either 1 == length? str [
                first str
            ][
                str
            ]
        ]

        fail "Unhandled type to quoth-mu"
    ]
]

export insert-at-mu: lambda [
    {Just insert and at combined}
    series
    index
    value
][
    insert at series index value
]

export increment-mu: lambda ['word-or-path] [
    get :word-or-path
    elide (
        either path? :word-or-path [
            set :word-or-path add-mu old 1
        ][
            set word-or-path add-mu get :word-or-path 1
        ]
    )
]

export decrement-mu: lambda ['word-or-path ] [
    get :word-or-path
    elide (
        either path? :word-or-path [
            set :word-or-path subtract-mu old 1
        ][
            set word-or-path subtract-mu get :word-or-path 1
        ]
    )
]

export readin-mu: lambda [
    {Use data type after getting the quoted argument to determine input coercion}
    'value
][
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    switch type of get value [
        text! [prin "Input String: " set value input]
        integer! [set value to-integer ask "Input Integer: "]
        decimal! [set value to-integer ask "Input Float: "]
        block! [set value to-block ask "Input Series of Items: "]
        percent! [set value to-percent ask "Input Percent: "]

        fail "Unhandled type to readin-mu"
    ]
]

; Don't think want to call it not-mu because we probably want a more powerful
; operator defined as ~ in order to compete with GolfScript/etc, rethink this.
export inversion-mu: lambda [
    value
][
    switch type of :value [
        text! [empty? value]
        decimal!
        integer! [
            zero? value
        ]
    ] else [
        not value
    ]
]

export next-mu: lambda [arg] [
    switch type of :arg [
        integer! [arg + 1]
    ] else [
        next arg
    ]
]

export back-mu: lambda [arg] [
    switch type of :arg [
        integer! [arg - 1]
    ] else [
        back arg
    ]
]

export collect-mu: adapt :collect [  ; like COLLECT but K and KP shorthands for KEEP
    body: compose [
        k: kp: :keep
        (as group! body)
    ]
]

export remove-each-mu: lambda [
    'word [get-word! word! block!]
    data [any-series!]
    body [block!]
][
    remove-each :word data body
    data
]

export swap-exchange-mu: lambda [
    "Swap contents of variables."
    a [word! any-series!
        ; gob! is in r3 only
    ]
    b [word! any-series!
        ; gob! is in r3 only
    ]
][
    if not equal? (type of a) (type of b) [
        fail "swap-mu must be used with common types"
    ]
    either word? a [
        x: get a
        set a get b
        set b x
    ][
        swap a b
    ]
]

export div-mu: lambda [value1 value2] [
    to-integer divide value1 value2
]

export add-mu: lambda [value1 value2] [
    switch type of :value1 [
        text! [
            skip value1 value2
        ]
        block! [
            result: copy value1
            while [(not tail? value1) and (not tail? value2)] [
                change result add-mu first result first value2
                ++ result
                ++ value2
            ]
            head result
        ]
    ] else [
        add value1 value2
    ]
]

export subtract-mu: lambda [value1 value2] [
    switch type of :value1 [
        block! [
            result: copy value1
            while [(not tail? value1) and (not tail? value2)] [
                change result subtract-mu first result first value2
                ++ result
                ++ value2
            ]
            head result
        ]
    ] else [
        subtract value1 value2
    ]
]

export negate-mu: lambda [value] [
    switch type of :value [
        block! [
            result: copy value
            while [not tail? value] [
                change result negate-mu first value
                ++ result
                ++ value
            ]
            head result
        ]
    ] else [
        negate value
    ]
]

export add-modify-mu: lambda ['value value2] [
    set :value add-mu get :value value2
]

export subtract-modify-mu: lambda ['value value2] [
    set :value subtract-mu get :value value2
]

export equal-modify-mu: lambda ['value value2] [
    set :value equals? get :value value2
]

export next-modify-mu: lambda ['value value2] [
    set :value next get :value value2
]

export back-modify-mu: lambda ['value value2] [
    set :value back get :value value2
]

export change-modify-mu: lambda ['series value] [
    change get :series value
    elide first+ :series
]

export head-modify-mu: lambda ['series] [
    set :series head get :series
]

export tail-modify-mu: lambda ['series] [
    set :series tail get :series
]

export skip-modify-mu: lambda ['series offset] [
    set :series skip get :series offset
]

export pre-parse-mu: use [digit lower-alpha upper-alpha hex-digit subs] [
    digit: charset [#"0" - #"9"] ; digits charset
    hex-digit: charset [#"0" - #"9" #"A" - #"F" #"a" - #"f"] ; hex charset
    upper-alpha: charset [#"A" - #"Z"] ; uppercase
    lower-alpha: charset [#"a" - #"z"] ; lowercase

    subs: [
        sm some
        an any
        th thru
        cp copy
        st set
        dg digit
        hx hex-digit
        la lower-alpha
        ua upper-alpha
    ]

    function [parse-rule [block!]] [
        rule: [
            mark: [
                'sm | 'an | 'th | 'cp | 'st | 'dg | 'hx | 'la | 'ua
            ] (change mark select subs mark.1)
            | and block! into [some rule]
            | skip
        ]

        parse parse-rule [some rule]
        return parse-rule
    ]
]

export parse-mu: func [input [any-series!] rules [block! text! char! blank!]] [
    if block? rules [rules: pre-parse-mu rules]
    return parse/case input rules
]

export ceiling-mu: lambda [value] [
    to-integer round/ceiling value
]

Rebol [
    Title: "The Mu Rebol Library"

    Description: {
        This is a library generally designed to be used with abbreviated
        symbols in Rebmu.  While there is a fuzzy line between "library" and
        "language", the intention is not to achieve a low symbol count at the
        cost of creating something that is incompatible with Rebol.

        For instance: it might be expedient in Code Golf to have the conditonal
        logic treat 0 as a "false" condition.  But since Rebol's IF treats 0
        as true, we do too.  On the other hand, IT (if-true?-mu, aliased to I)
        *does* accept words and constants in its true-clause block. Rebol would
        throw an error on such constructs, so a Rebmu program which ascribes
        meaning to that is forwards compatible with existing Rebol programming
        knowledge.

        Ultimately, Code Golf cannot be played with a language and library
        set that is allowed to expand during a competition.  So the Rebmu
        library will have to stabilize into a fixed set at some point - likely
        including many matrix operations.
    }
]

to-string-mu: function [
    value
] [
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
    ] [
        to-string value
    ]
]

to-char-mu: function [
    value
] [
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
    ] [
        to-char value
    ]

]

to-word-mu: function [value] [
    either char? value [
        to-word to-string value
    ] [
        to-word value
    ]
]

to-http-url-mu: function ['target [word! path! string!] /secure][
	join either secure [https://][http://] target
]

caret-mu: function ['value] [
    switch/default type?/word :value [
        string! [return to-string debase value]
    ] [
        throw "caret mu needs to be thought out for non-strings, see rebmu.reb"
    ]

]

redefine-mu: func ['dest 'source] [
    ;-- Has to be a FUNC to set in caller's environment...
    ;-- or does it?  Look into that.

    set :dest get :source
]

if-greater?-mu: function [
    value1
    value2
    true-branch
] [
    if greater? value1 value2
        true-branch
]

if-unequal?-mu: function [
    value1
    value2
    true-branch
] [
    if not-equal? value1 value2
        true-branch
]

if-equal?-mu: func [
    value1
    value2
    true-branch
] [
    if equal? value1 value2
        true-branch
]

if-zero?-mu: func [
    value
    true-branch
] [
    if zero? value
        true-branch
]

if-lesser?-mu: func [
    value1
    value2
    true-branch
] [
    if lesser? value1 value2
        true-branch
]

unless-zero?-mu: func [
    value
    false-branch
] [
    unless zero? value
        false-branch
]

either-zero?-mu: func [
    value
    true-branch
    false-branch
] [
    either zero? value
        true-branch
        false-branch
]

either-greater?-mu: func [
    value1
    value2
    true-branch
    false-branch
] [
    either greater? value1 value2
        true-branch
        false-branch
]

either-lesser?-mu: func [
    value1
    value2
    true-branch
    false-branch
] [
    either lesser? value1 value2
        true-branch
        false-branch
]

either-equal?-mu: func [
    value1
    value2
    true-branch
    false-branch
] [
    either equal? value1 value2
        true-branch
        false-branch
]

either-unequal?-mu: func [
    value1
    value2
    true-branch
    false-branch
] [
    either not-equal? value1 value2
        true-branch
        false-branch
]

while-greater?-mu: function [
    value1
    value2
    body-param
] [
    while [greater? value1 value2]
        body-param
]

while-lesser-or-equal?-mu: function [
    value1
    value2
    body-param
] [
    while [lesser-or-equal? value1 value2]
        body-param
]

while-greater-or-equal?-mu: function [
    value1
    value2
    body-param
] [
    while [greater-or-equal? value1 value2]
        body-param
]

while-lesser?-mu: function [
    value1
    value2
    body-param
] [
    while [lesser? value1 value2]
        body-param
]

while-equal?-mu: function [
    value1
    value2
    body-param
] [
    while [equal? value1 value2 cond-param]
        body-param
]

while-unequal?-mu: function [
    value1
    value2
    body-param
] [
    while [not-equal? value1 value2 cond-param]
        body-param
]

make-matrix-mu: function [columns value rows] [
    result: copy []
    loop rows [
        append/only result array/initial columns value
    ]
    result
]

make-string-initial-mu: function [length value] [
    result: copy ""
    loop length [
        append result value
    ]
    result
]

; if a pair, then the first digit is the digit
make-integer-mu: function [value] [
    switch/default type?/word :value [
        pair! [to-integer first value * (10 ** second value)]
        integer! [to-integer 10 ** value]
    ] [
        throw "Unhandled type to make-integer-mu"
    ]
]

; helpful is a special routine that quotes its argument and lets you pick from
; common values.  for instance helpful-mu d gives you a charaset of digits.
; Passing an integer into helpful-mu will just call make-integer-mu.  This is
; just an exploration of using this concept to shorten code.
helpful-mu: function ['arg] [
    switch/default type?/word :arg [
        word! [
            switch/default arg [
                b: [0 1] ; binary digits
                d: charset [#"0" - #"9"] ; digits charset
                h: charset [#"0" - #"9" #"A" - "F" #"a" - #"f"] ; hex charset
                u: charset [#"A" - #"Z"] ; uppercase
                l: charset [#"a" - #"z"] ; lowercase
            ]
        ]
        ; Are there better ways to handle this?
        ; h2 for instance is no shorter than 20
        integer! [make-integer-mu arg]
        pair! [make-integer-mu arg]
    ] [
        throw "Unhandled parameter to helpful-mu"
    ]
]

; An "a|funct" is a function that takes a single parameter called a, you only
; need to supply the code block.  obvious extensions for other letters.  The
; "func|a" is the same for funcs

function-a-mu: func [body [block!]] [
    function [a] body
]
function-ab-mu: func [body [block!]] [
    function [a b] body
]
function-abc-mu: func [body [block!]] [
    function [a b c] body
]
function-abcd-mu: func [body [block!]] [
    function [a b c d] body
]

function-z-mu: func [body [block!]] [
    function [z] body
]
function-zy-mu: func [body [block!]] [
    function [z y] body
]
function-zyx-mu: func [body [block!]] [
    function [z y x] body
]
function-zyxw-mu: func [body [block!]] [
    function [z y x w] body
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

does-function-mu: func [body [block!]] [
    function [] body
]


quoth-mu: function [
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

index?-find-mu: function [
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

insert-at-mu: function [
    {Just insert and at combined}
    series
    index
    value
] [
    insert at series index value
]

increment-mu: func ['word-or-path] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    either path? :word-or-path [
        old: get :word-or-path
        set :word-or-path add-mu old 1
    ] [
        set word-or-path add-mu get :word-or-path 1 
    ]
]

decrement-mu: func ['word-or-path] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    either path? :word-or-path [
        old: :word-or-path
        set :word-or-path subtract-mu old 1
    ] [
        set word-or-path subtract-mu get :word-or-path 1
    ]
]

readin-mu: func [
    {Use data type after getting the quoted argument to determine input coercion}
    'value
] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    switch/default type?/word get value [
        string! [prin "Input String: " set value input]
        integer! [set value to-integer ask "Input Integer: "]
        decimal! [set value to-integer ask "Input Float: "]
        block! [set value to-block ask "Input Series of Items: "]
        percent! [set value to-percent ask "Input Percent: "]
    ] [
        throw "Unhandled type to readin-mu"
    ]
]

writeout-mu: function [
    {Analogue to Rebol's print except tailored to Code Golf scenarios}
    value
] [
    ; better implementation coming, maybe.  Have to think.
    ; had a matrix printer but abandoned it for Rebol's default
    ; starting to think that w should start as "while" as reading input
    ; and writing it out is not something that necessarily needs a small
    ; character space
    print value
]

; Don't think want to call it not-mu because we probably want a more powerful
; operator defined as ~ in order to compete with GolfScript/etc, rethink this.
inversion-mu: function [
    value
] [
    switch/default type?/word :value [
        string! [empty? value]
        decimal!
        integer! [
            zero? value
        ]
    ] [
        not value
    ]
]

next-mu: function [arg] [
    switch/default type?/word :arg [
        integer! [arg + 1]
    ] [
        next arg
    ]
]

back-mu: function [arg] [
    switch/default type?/word :arg [
        integer! [arg - 1]
    ] [
        back arg
    ]
]

collect-mu: function [body [block!] /into output [series!]] [
    unless output [output: make block! 16]
    do func [kp] body func [value [any-type!] /only] [
        output: apply :insert [output :value none none only]
        :value
    ]
    either into [output] [head output]
]

remove-each-mu: function [
    'word [get-word! word! block!]
    data [series!]
    body [block!]
] [
    remove-each :word data body
    data
]

swap-exchange-mu: func [
    "Swap contents of variables."
    a [word! series!
        ; gob! is in r3 only
    ]
    b [word! series!
        ; gob! is in r3 only
    ]
][
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

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

div-mu: function [value1 value2] [
    to-integer divide value1 value2
]

add-mu: function [value1 value2] [
    switch/default type?/word :value1 [
        string! [
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
    ] [
        add value1 value2
    ]
]

subtract-mu: function [value1 value2] [
    switch/default type?/word :value1 [
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

negate-mu: function [value] [
    switch/default type?/word :value [
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

add-modify-mu: func ['value value2] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :value add-mu get :value value2
]

subtract-modify-mu: func ['value value2] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :value subtract-mu get :value value2
]

equal-modify-mu: func ['value value2] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :value equals? get :value value2
]

next-modify-mu: func ['value value2] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :value next get :value value2
]

back-modify-mu: func ['value value2] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :value back get :value value2
]

change-modify-mu: func ['series value] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    also [change get :series value] [first+ :series]
]

head-modify-mu: func ['series] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :series head get :series
]

tail-modify-mu: func ['series] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :series tail get :series
]

skip-modify-mu: func ['series offset] [
    ;-- Has to be a FUNC to set in callers environment...
    ;-- ...or could we leverage the caller's binding?

    set :series skip get :series offset
]

pre-parse-mu: use [digit lower-alpha upper-alpha hex-digit subs] [
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
            ] (change mark select subs mark/1)
            | and block! into [some rule]
            | skip
        ]

        parse parse-rule [some rule]
        parse-rule
    ]
]

parse-mu: func [input [series!] rules [block! string! char! none!]] [
    if block? rules [rules: pre-parse-mu rules]
    parse/case input rules
]

; -1 is a particularly useful value, yet it presents complications to mushing
; that ON does not have.  Also frequently, choosing 1 vs -1 depends on a logic.
; Onesigned turns true into 1 and false into -1 (compared to to-integer which
; treats false as zero)
onesigned-mu: function [value] [
    either to-boolean value [1] [-1]
]

ceiling-mu: function [value] [
    to-integer round/ceiling value
]

not-mu: function [value] [
    not true? value
]

only-first-true-mu: function [value1 value2] [
    all [
        true? value1
        not true? value2
    ]
]

only-second-true-mu: function [value1 value2] [
    all [
        true? value2
        not true? value1
    ]
]

prefix-or-mu: function [value1 value2] [
    any [
        true? value1
        true? value2
    ]
]

prefix-and-mu: function [value1 value2] [
    all [
        true? value1
        true? value2
    ]
]

prefix-xor-mu: function [value1 value2] [
    (true? value1) xor (true? value2)
]

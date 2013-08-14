REBOL [
    Title: "Mushing Routines"

    Author: "Dr. Rebmu"
    Home: http://rebmu.rebol.net/
    License: 'bsd

    Date: 29-Jul-2013
    Version: 0.3.0

    ; Header conventions: http://www.rebol.org/one-click-submission-help.r
    File: %mushing.rebol
    Type: dialect
    Level: advanced

    Description: {

    Routines implementing the concept of "mushing".  Mushed Rebol still
    passes the parser but uses particular sequences of upper and lower
    case terms and symbol processing within words to achieve approximately
    40% reduction in the average character count of the abbreviated form:

        >> unmush [abcDEFghi]
        == [abc def ghi]

    The choice to start a sequence of alternations with an uppercase run
    is used as a special indicator of wishing the first element in the
    sequence to be interpreted as a set-word:

        >> unmush [ABCdefGHI]
        == [abc: def ghi]

    This applies to elements of paths as well.  Each path break presents
    an opportunity for a new alternation sequence, hence a set-word split:

        >> unmush [ABCdef/GHI]
        == [abc: def/ghi:]

        >> unmush [ABCdef/ghi]
        == [abc: def/ghi]

    An exception to this rule are literal words, where since you cannot
    make a literal set-word in source the purpose is to allow you to
    indicate whether the *next* word should be a set-word.  Choosing
    lowercase for the lit word will mean the next word is a set-word,
    while uppercase means it will not be:

        >> unmush [abc'DEFghi]
        == [abc 'def ghi]

        >> unmush [abc'defGHI]
        == [abc 'def ghi:]

    A get-word! cannot be made inline like this, because colons are
    used in URL types (even a:b is a url!).  But in the one case of
    leading colons, the same rule applies to the capitalization,
    indicating whether the second word will be a set-word or not:

        >> unmush [:abcDEFghi]
        == [:abc def: ghi]

        >> unmush [:ABCdefGHI]
        == [:abc def ghi]

    A source-level set-word might seem to most sensibly make the
    last run a set-word.  But if you want [abc: def ghi:] then it is
    just as many characters to write [ABCdef GHI] as [ABCdefGHI:],
    so a cooler gimmick is needeed

        TBD: what cool trick should this enable?

    Because symbols do not have a "case" they are handled specially.
    Since Rebmu tries to be compatible with Rebol code (as long as it's
    all lowercase!) they generally act like lowercase letters, with a few
    caveats:

        ; lowercase run to another lowercase, will act lowercase
        [a+b] => [a+b]

        ; implied lowercase, again compatible with ordinary Rebol
        [+b] => [+b]

        ; uppercase run to another uppercase, splits symbol out
        [A+B] => [a: + b]

        ; switching lower to upper, symbol binds to the tail of first
        [a+B] => [a+ b]

        ; switching upper to lower, symbol binds to the head of second
        [A+b] => [a: +b]

        ; all one token, has to be compatible with ordinary Rebol
        [a++b] => [a++b]

        ; surprise!  multiple symbols bind into their own token
        [A++b] => [a: ++ b]

        ; caps after a multi symbol break starts a new word
        [a++B] => [a ++ b]

        ; pursuant to the above
        [A++B] => [a: ++ b]

    Digits are handled mostly the same as symbols, in that they will
    bind in a word as a single digit but stand alone in larger
    groups.  This makes initializations easy:

        [A10B20C00] => [a: 10 b: 20 c: 0]

    There is a difference from symbol, when you switch from upper to
    lowercase across a single digit.  It would not make sense for it
    to bind to the head of the next symbol (invalid integer) so 
    instead it sticks to the left:

        [A0b] => [a0: b]

    It's important to notice that unless there is an uppercase letter
    *somewhere* in your words, the mushing will not be applied.  So
    the mushing rules wouldn't apply in this case, for instance:

        [a00] => [a00]

    The number of spaces and colons this can save on in Rebol code is
    significant, and it is easy to read and write once the rules are
    understood.  If you know Rebol, that is :)

    This file might be expanded to include an automatic mushing routine
    However, it is important to bear in mind that the point of Rebmu
    is to provide a language which despite achieving a low character
    count is still fairly feasible to code in without using an assistive
    mechanical preprocessor or compiler.
    }
]

upper: charset [#"A" - #"Z"]
lower: charset [#"a" - #"z"]
digit: charset [#"0" - #"9"]
symbol: charset [#"!" #"?" #"^^" #"|" #"*" #"+" #"-" #"~" #"&" #"=" #"." #"`"]

unmush: funct [
    {Take any Rebol symbol or structure, and recursively apply a decoding
    known as "unmushing" on it...where the usage of capital letters cues
    special handling for inserting spaces or converting runs of
    characters inside a single symbol into separate symbols.}
    value [any-type!]
] [
    case [
        any-word? :value [
            ;
            ; If there's no capitalization used, we want to remain compatible
            ; with Rebol code
            ;
            value-string: to string! :value
            unless find/case value-string upper [
                return :value
            ]

            ;
            ; For word types other than WORD!, it's not the capitalization
            ; of the first run that determines the type.  Because the
            ; word type of the first run is the type of the word.  Instead
            ; the capitalization of the second run determines whether the
            ; *second* word is to be a SET-WORD! or not.
            ;
            target-type: type? :value
            caps-means-set: either target-type = word! [
                found? find upper first value-string
            ] [
                true
            ]

            make-lone-rule: func [rule] [
                compose [(rule) not (rule)]
            ]

            ;
            ; would be nice if we could call functions from parse and use
            ; the result as a rule...!
            ;
            lone-digit: make-lone-rule digit
            lone-symbol: make-lone-rule symbol
            lone-apostrophe: make-lone-rule {'}
            lone-colon: make-lone-rule {:}

            result: copy []

            assert [parse/case value-string [
                some [
                    opt [
                        lone-apostrophe (
                            target-type: lit-word!
                            caps-means-set: true
                        )
                    ]
                    opt [
                        lone-colon (
                            target-type: get-word!
                            caps-means-set: true
                        )
                    ]

                    begin-run:

                    [
                        opt symbol some lower (
                            if target-type = word! [
                                caps-means-set: false
                            ]
                        )
                        opt [lone-digit | lone-symbol]
                    |
                        some upper
                        opt [[lone-digit | lone-symbol] if (not caps-means-set)] (
                            if caps-means-set and (target-type = word!) [
                                target-type: set-word!
                                caps-means-set: false
                            ]
                        )
                    |
                        some symbol (
                            caps-means-set: false
                        )
                    |
                        some digit (
                            target-type: integer!
                            caps-means-set: true
                        )
                    ]

                    end-run:

                    (
                        run-string: lowercase copy/part begin-run end-run

                        comment [
                            ;
                            ; This is what I want to do, but the binding isn't good.
                            ; it doesn't find things in the system context, like FALSE
                            ;
                            target: to target-type run-string
                            bind target bind? value  ;-- doesn't help...
                        ]

                        case [
                            target-type = lit-word! [insert run-string {'}]
                            target-type = set-word! [append run-string {:}]
                            target-type = get-word! [insert run-string {:}]
                            target-type = word! []
                            target-type = integer! []
                            true [
                                print target-type
                                throw "Not implemented."
                            ]
                        ]
                        target: load run-string

                        append result :target
                        target-type: word!
                    )
                ]
            ] ]

            either 1 = length? result [
                return result/1
            ] [
                return result
            ]
        ]

        ;
        ; If the value is a path then it will generate at least one unmushed
        ; path, and possibly more.  For instance, this three element path
        ; produces a SET-WORD!, a SET-PATH!, and a PATH!
        ;
        ;     ABCdef/GHIjkl/mno => [abc: def/ghi: jkl/mno]
        ;
        path? value [
            ;
            ; We build the result backwards, as it is the last element in an unmushed
            ; path sequence that tells us if we're making a PATH! or SET-PATH!
            ;
            ;     ABCdef/GHIjkl/mno => [[abc: def] [ghi: jkl] mno]
            ;
            ; The number of paths we'll have in our result will be either the number
            ; of blocks in this result, or just one for the original path if nothing
            ; was unmushed.
            ;
            result: copy []
            temp-path: none
            pos: back tail value
            forever [
                unmushed: unmush pos/1
                next-path-symbol: none

                either block? unmushed [
                    if temp-path [
                        ;
                        ; the last element of this block becomes the head of our working
                        ; path, and we're done constructing it so add to the result
                        ;
                        insert temp-path take/last unmushed
                        insert/only result temp-path
                        temp-path: none
                    ]
                    if not head? pos [
                        ;
                        ; any blocks not at the beginning create discontinuity,
                        ; and their first element is the last element of some path
                        ;
                        next-path-symbol: take unmushed
                    ] 
                    ;
                    ; any symbols left over in the block after the above two
                    ; checks aren't parts of a path, so insert them as-is
                    ; 
                    insert result unmushed
                ] [
                    ;
                    ; If the unmush didn't return a block, then just consider its
                    ; symbol to be the next element for the path in progress
                    ; 
                    next-path-symbol: unmushed
                ]

                ;
                ; Add the next symbol to the inn-progress path if applicable.
                ; Create the path if necessary, using the type of the symbol to
                ; cue whether it needs to be a SET-PATH! or a PATH!
                ;
                if next-path-symbol [
                    if not temp-path [
                        either set-word? next-path-symbol [
                            temp-path: make set-path! []
                            next-path-symbol: to word! next-path-symbol
                        ] [
                            temp-path: make path! []
                        ]
                    ]
                    insert temp-path next-path-symbol
                ]

                ;
                ; If we've reached the head of the input path, then emit
                ; any in progress path being built and break the loop
                ;
                if head? pos [
                    if temp-path [
                        insert/only result temp-path
                        temp-path: none
                    ]

                    break
                ]

                pos: back pos
            ]

            either 1 = length? result [
                return result/1
            ] [
                return result
            ]
        ]

        ;
        ; For now, all non-path block types are handled by unmushing each element.
        ; But if the result of the unmushing is a block of symbols and the original
        ; value was not a block, then the elements are spliced into the series
        ;
        any-block? value [
            result: make type? value []
            foreach elem value [
                unmushed: unmush elem
                either all [
                    not block? elem
                    block? unmushed
                ] [
                    append result unmushed 
                ] [
                    append/only result unmushed
                ]
            ]
            return result
        ]
    ]

    ;
    ; String literals and other types are currently returned as-is
    ;
    return value
]

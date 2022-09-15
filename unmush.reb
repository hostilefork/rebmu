Rebol [
    Title: "Unmushing Routine"

    Author: "Dr. Rebmu"
    Home: http://rebmu.rebol.net/
    License: 'bsd

    Date: 29-Jul-2013
    Version: 0.3.0

    ; Header conventions: http://www.rebol.org/one-click-submission-help.r
    File: %unmush.reb
    Type: module
    Name: Unmush
    Level: advanced

    Description: {
        See README.md in GitHub for the workings of mushing.

        See mush.reb for an automatic musher (work in progress).

        However, it is important to bear in mind that the point of Rebmu
        is to provide a language which despite achieving a low character
        count is still fairly feasible to code in without using an assistive
        mechanical preprocessor or compiler.  Err on the side of using
        mush as a runtime tool in the problem solution itself (such as for
        writing quines)... *not* as a crutch to write your code as Rebol
        first, then convert it!  You're missing out on the fun, then.  :-)
    }
]


export unmush: function [
    {Decode packed Rebmu data like "AxBy" into blocks like [a: x b: y]}
    value [any-value!]
][
    upper: charset [#"A" - #"Z"]
    lower: charset [#"a" - #"z"]
    digit: charset [#"0" - #"9"]
    symbol: charset [#"!" #"?" #"^^" #"|" #"*" #"+" #"-" #"~" #"&" #"=" #"." #"`"]

    case [
        any-word? :value [
            ;
            ; If there's no capitalization used, we want to remain compatible
            ; with Rebol code
            ;
            value-string: to text! :value
            if not find/case value-string upper [
                return :value
            ]

            ;
            ; For word types other than WORD!, it's not the capitalization
            ; of the first run that determines the type.  Because the
            ; word type of the first run is the type of the word.  Instead
            ; the capitalization of the second run determines whether the
            ; *second* word is to be a SET-WORD! or not.
            ;
            target-type: type of value
            caps-means-set: did any [
                target-type = word!
                find upper first value-string
            ]

            make-lone-rule: lambda [rule] [
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

            assert [did parse/case value-string [
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

                    begin-run: <here>

                    [
                        opt symbol some lower (
                            if target-type = word! [
                                caps-means-set: false
                            ]
                        )
                        opt [lone-digit | lone-symbol]
                    |
                        some upper
                        opt [[lone-digit | lone-symbol] :(not caps-means-set)] (
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

                    end-run: <here>

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
                        ] else [
                            fail [target-type "Not implemented."]
                        ]

                        target: load run-string

                        append result spread target
                        target-type: word!
                    )
                ]
            ]]

            either length of result = 1 [
                return :result.1
            ][
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
                unmushed: unmush pos.1
                next-path-symbol: none

                either block? :unmushed [
                    if temp-path [
                        ;
                        ; the last element of this block becomes the head of our working
                        ; path, and we're done constructing it so add to the result
                        ;
                        insert temp-path take/last :unmushed
                        insert result temp-path
                        temp-path: none
                    ]
                    if not head? pos [
                        ;
                        ; any blocks not at the beginning create discontinuity,
                        ; and their first element is the last element of some path
                        ;
                        next-path-symbol: take :unmushed
                    ]
                    ;
                    ; any symbols left over in the block after the above two
                    ; checks aren't parts of a path, so insert them as-is
                    ;
                    insert result spread unmushed
                ][
                    ;
                    ; If the unmush didn't return a block, then just consider its
                    ; symbol to be the next element for the path in progress
                    ;
                    next-path-symbol: :unmushed
                ]

                ;
                ; Add the next symbol to the in-progress path if applicable.
                ; Create the path if necessary, using the type of the symbol to
                ; cue whether it needs to be a SET-PATH! or a PATH!
                ;
                if :next-path-symbol [
                    if not temp-path [
                        either set-word? :next-path-symbol [
                            temp-path: make set-path! []
                            next-path-symbol: to word! :next-path-symbol
                        ][
                            temp-path: make path! []
                        ]
                    ]
                    insert/only temp-path :next-path-symbol
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
                return :result.1
            ][
                return result
            ]
        ]

        ;
        ; For now, all non-path block types are handled by unmushing each element.
        ; But if the result of the unmushing is a block of symbols and the original
        ; value was not a block, then the elements are spliced into the series
        ;
        any-array? value [
            result: as (type of value) copy []
            for-each elem value [
                unmushed: unmush :elem
                all [
                    not block? :elem
                    block? :unmushed
                ] then [
                    append result spread unmushed
                ] else [
                    append result :unmushed
                ]
            ]

            return result
        ]
    ]

    ;
    ; String literals and other types are currently returned as-is
    ;
    return :value
]

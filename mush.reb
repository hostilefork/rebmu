Rebol [
    Title: "Mush"
    Purpose: "MOLD a block in Mushed form"
    Date: 14-Jul-2014
    Author: "Christopher Ross-Gill"
    Version: 0.1.0
    License: 'bsd
    History: [
        0.1.0 [14-Jul-2014 {First pass at a Mushing function. Limited scope:

        * Returns a string
        * Does not discern word structure e.g. for separate handling of
          words with numbers or symbols
        * Few special cases for minimizing space between two values
        * Uses MOLD and not MOLD/ALL
        * Does not replace Rebol words with their RebMu counterpart
        * NOT RIGOROUSLY TESTED}]
    ]
]

mush: function [
    {Applies Mushing to a Block}
    source [any-type!] {Block to be Mushed}
    ; /local rule value space last-type lower? mark
][
    rejoin collect [
        unless parse reduce [source] rule: [
            (
                space: ""
                last-type: none
            )

            any [
                mark: (value: none)

                ; Blocks: no space before, no space after
                [
                    block! :mark
                    (
                        keep "["
                    )
                    into rule
                    (
                        keep "]"
                        space: ""
                        last-type: block!
                    )
                ]

                | ; Parens: space before, no space after
                [
                    paren! :mark (
                        keep space
                        keep "("
                    )
                    into rule
                    (
                        keep ")"
                        space: ""
                        last-type: paren!
                    )
                ]

                | ; Words and Set-Words: space before, space after, no space between
                [
                    copy value [set-word! any word! | some word!] (
                        lower?: true
                        keep space

                        if set-word? value/1 [
                            keep uppercase mold to word! take value
                            last-type: set-word!
                        ]

                        foreach word value [
                            keep either lower? [lowercase mold word][uppercase mold word]
                            lower?: not lower?
                            last-type: word!
                        ]

                        space: " "
                    )
                ]

                | ; Other Values: space before, space after (unless where exceptions)
                [
                    set value skip (
                        unless any [

                            ; Exceptions
                            case [
                                last-type = set-word! [
                                    any [
                                        number? value
                                        string? value
                                        tag? value
                                    ]
                                ]
                                last-type = word! [
                                    any [
                                        string? value
                                        tag? value
                                    ]
                                ]
                            ]
                        ][keep space]

                        keep mold value
                        space: either any [

                            ; Exceptions
                            find [tag! string!] type?/word value
                        ][""][" "]
                        last-type: type? value
                    )
                ]
            ]
        ][
            keep "<< Mush Error"
        ]
    ]
]

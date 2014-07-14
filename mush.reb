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
    {Mushes words in a block}
    source [any-block!] {Block containing words to be mushed}
][
    head collect/into [
        words: either any-path? source [
            [set value [set-word! | word!] (keep value)]
        ][
            [
                copy value [set-word! any word! | some word!] (
                    lower?: true

                    keep to word! rejoin collect [
                        if set-word? value/1 [
                            keep uppercase mold to word! take value
                        ]

                        foreach word value [
                            keep either lower? [lowercase mold word][uppercase mold word]
                            lower?: not lower?
                        ]
                    ]
                )
            ]
        ]

        parse source [
            any [
                set value any-block! (keep/only mush value)
                |
                words
                |
                set value skip (keep :value)
            ]
        ]
    ] make type? source length? source
]

mold-compact: function [
    {Converts a value to a Rebol-readable string (compact)}
    source [any-type!] {The value to mold}
    /only {For a block value, mold only its contents, no outer []}
][
    rejoin collect [
        unless parse either only [source][reduce [source]] rule: [
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

                        keep mold :value
                        space: either any [

                            ; Exceptions
                            find [tag! string!] type?/word value
                        ][""][" "]
                        last-type: type? value
                    )
                ]
            ]
        ][
            keep "<< Mold-Compact Error"
        ]
    ]
]

mush-and-mold: function [value [any-block!] /only][
    apply :mold-compact [mush value only]
]
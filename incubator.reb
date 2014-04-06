Rebol [
    Title: {Rebol/Red proposal incubator}

    Description: {
        These are not in the MU-library because they are not Rebmu specific
        tricks, rather things that could have a general purpose in Rebol
        and/or have been proposed but not fully standardized.
    }
]

flatten: func [
    data
    /local rule
] [
    local: make block! length? data
    rule: [
        into [some rule]
    |   set value skip (append local value)
    ]
    parse data [some rule]
    local
]

; The COMBINE function, proposed but not yet in mainline Rebol/Red
; Useful enough to shim for Rebmu for advance testing
;
; http://curecode.org/rebol3/ticket.rsp?id=2142&cursor=1 
;
; Skeletal adaptation taken from RECAT by @rebolek as presented in chat
combine: func [
    block [block!]
    /with "Add delimiter between values"
        delimiter
    /all "Don't remove none from the input"
    ; /only ... not implemented
    ; /deep ... not implemented
] [
    block: reduce block
    if empty? block [return block]
    unless all [block: trim block]
    if with [
        with: make block! 2 * length? block
        foreach value block [repend with [value delimiter]]
        block: head remove back tail with
    ]
    either any-string? first block [
        append (make type? first block length? block) block
    ] [
        append (make block! length? block) flatten block
    ]
]

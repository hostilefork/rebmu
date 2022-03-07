Rebol [
    Title: "Rebmu Dialect"
    Purpose: {
        Rebol dialect designed for participating in "Code Golf"
        challenges
    }

    Author: {"Dr. Rebmu"}
    Home: http://rebmu.hostilefork.com
    License: 'mit

    Date: 15-Sep-2015
    Version: 0.7.0

    ; Header conventions: http://www.rebol.org/one-click-submission-help.r
    File: %rebmu.reb
    Type: 'dialect
    Level: 'genius

    Notes: {

        ### SINGLE CHARACTER DEFINITIONS

        Originally Rebmu tried to define single characters as having values
        so you could have "a value of that type around" (x, y, z as 0.0 to
        have a float around, s as {} to have an empty string, etc.)

        Thought to be helpful for golfing, it turned out to not be THAT
        helpful.  The trivial puzzles in which that count wasn't lost in the
        noise were usually solvable in fewer characters by another language
        that was a precise match for the domain of the question.  It was
        difficult to remember and taught nothing that would be relevant to
        Rebol or Red.

        So the single character definitions were scaled back drastically.
        They are tracked here as an index and to-do list, while the actual
        definitions are in the functional group in the code.

        . => redefine-mu
        & => does/only (a.k.a. historical DOES with no locals gathering)
        ~
        ?
        |
        a ;-- usually a program argument or a-function variable
        b
        c => copy
        d
        e => either
        f => for-each
        g
        h
        i => if
        j
        k
        l => loop
        m
        n
        o
        p => print
        q => quote ;-- Q is not QUIT in proposals, so not overriding
        r => repeat
        s
        t => to ;-- note: can use example types, e.g. t "foo" 10 is "10"
        u => unless (vs. IF NOT as iNT or Int)
        v
        w => while
        x
        y
        z


        ### EXISTING TWO-CHARACTER SPACE

        Because there are only so many single characters (unless you start
        using Unicode...) the majority of Rebmu function definitions live
        in the two-character space.  However, refinements follow a system...
        so even if it would be *possible* to do APPEND/ONLY => AO, such
        compression tricks are seen as less consistent than if you have
        APPEND => AP and APPEND/ONLY => APO.  So the two-character space
        is the baseline for growing further in a systemic way.

        Yet Rebol itself does define a few things already in the two character
        space that should not be overridden, to reach Rebmu's goal of being
        able to compatibly run any all-lowercase Rebol code in midstream.
        Here's a short study of the space used.

        Very Reasonable Use of English Words

            TO    to conversion
            OR    or operator (infix)
            IN    word or block in the object's context
            IF    conditional if
            DO    evaluates a block, file, url, function word
            AT    returns the series at the specified index
            NO    logic false
            ON    logic true

        Reasonably non-controversial use of Symbolic Operators

            ++    increment and return previous value
            --    decrement and return previous value
            >=    true if the first value is greater than the second (infix)
            <=    true if the first value is less than the second (infix)
            **    first number raised to the power of the second (infix)
            !=    true if the values are not equal (infix)

        More questionable Symbolic operator

            =?    true if the values are identical, === seems more logical

        Added by the rebol-proposals

            ~=    infix loose-equal?

        Maybe okay name for a debugging function

            ??    Debug print a word, path, block or such

        Unapplied in Rebol but used in Red for questionable benefit:

            <<    infix version of prefix shift left (why not strict-lesser?)
            >>    infix version of prefix shift right (why not strict-greater?)

        Bad things taken out by the proposals that shouldn't be legal:

            <>    same function as != yet is jarringly <tag>-like (infix)
            //    MODULO, but natural words shouldn't have slashes (infix)

        Deprecated shorthands for terms defined elsewhere, which have been
        reclaimed for Rebmu as "free terms" by the rebol-proposals (and should
        be removed from the language, existing only in console modes or
        user-preferences)

            RM    alias for DELETE
            DP    alias for DELTA-PROFILE
            DT    alias for DELTA-TIME
            LS    print contents of a directory
            CD    change directory
            DS    temporary stack debug

        It's worth pointing out that there is a proposal that would open up
        several more options in two-character space.  It's hard to predict
        how many of these might find meaningful default usaages in the box,
        such as -> or >< or |>- ... but sticking to two-character space
        these are what the proposals would define if they could:

            ~<    loose-lesser?
            ~>    loose-greater?


        ### SINGLE CHARACTER PLUS QUESTION MARK

        Several of these freed up with the requirement that ending in a ?
        actually return a LOGIC!.  The useful function empty? doesn't fit
        if E? is EQUAL? and EM? is EMAIL?

        A? => and?
        B? ;-- could be... block?
        C? ;-- could be... char?
        D? => distinct?
        E? => equal?
        F?
        G? => greater?
        H? => head?
        I? ;-- could be... integer?
        J?
        K?
        L? => lesser?
        M? => match? ;-- MM? is mismatch.
        N? => negative?
        O? => or?
        P? => positive?
        Q?
        R?
        S? => same?
        T? => tail? ;-- can't be TRUE?, TAIL? is more important
        U? => unequal?
        V? => value?
        W?
        X? => xor?
        Y? => true? ;-- (a.k.a. yes?)
        Z? => zero?
    }
]

; Functions that aren't mainline Rebol/Red at this point, but describe
; proposals which Rebmu is being used to test.

do %rebol-proposals/all-proposals.reb


; Load the modules implementing mush/unmush

do %mush.reb
do %unmush.reb


; Load the library of xxx-mu functions; tricks that are specific to Rebmu
; and would not seriously find their way into Rebol/Red mainline
;
; NOTE: While originally there was a tendency to be liberal with these,
; they are being excised as they can sort of be seen as interfering with
; Rebmu's main mission, which is to teach/evangelize Rebol and Red
; dialecting.  A trick just for the sake of helping win code golf that
; does not really assist with that (or worse, inhibits learning the
; languages proper) should be included sparingly--if at all

do %mulibrary.reb


; returns a block of definitions to include in the context
remap-datatype: function [type [datatype!] shorter [text!] /noconvert] [
    stem: head remove back tail to-text to-word type
    result: reduce [
        load-value rejoin [shorter "!" ":"] load-value rejoin [":" stem "!"]
        load-value rejoin [shorter "?" ":"] load-value rejoin [":" stem "?"]
    ]
    if not noconvert [
        append result reduce [
            load-value rejoin [shorter "-" ":"] load-value rejoin [":" "to-" stem]
        ]
    ]
    bind result system.contexts.user
]


rebmu-base-context: make object! compose [

    ;----------------------------------------------------------------------
    ; DATATYPE SHORTHANDS (3 CHARS)
    ; Though I considered giving the datatypes 2-character names, I decided
    ; on 3 (so IN! for INTEGER! instead of I!, in order that the test will
    ; be IN? with I? available for other purposes).  This is a decision
    ; which may be worth revisiting for some types, as INDEX? has become
    ; INDEX-OF in the language, so I? is free (for instance).  Not all
    ; types will fit in that space, however.
    ;----------------------------------------------------------------------

; Shorcuts for datatypes.  Establishes both the type and the query functions.
; (so remapping "em" for EMAIL! makes EM! => EMAIL! and EM? => EMAIL?)

    (remap-datatype email! "em")
    (remap-datatype block! "bl")
    (remap-datatype char! "ch")
    (remap-datatype decimal! "dc")
    (remap-datatype error! "er")
    (remap-datatype function! "fn")
    (remap-datatype get-word! "gw")
    (remap-datatype paren! "pn")
    (remap-datatype integer! "in")
    (remap-datatype pair! "pr")
    (remap-datatype percent! "pc")
    (remap-datatype closure! "cl")
    (remap-datatype logic! "lc")
    (remap-datatype map! "mp")
    (remap-datatype object! "ob")
    (remap-datatype path! "pa")
    (remap-datatype lit-word! "lw")
    (remap-datatype refinement! "rf")
    (remap-datatype string! "st")
    (remap-datatype time! "tm")
    (remap-datatype tuple! "tu")
    (remap-datatype file! "fi")
    (remap-datatype word! "wd")
    (remap-datatype tag! "tg")
    (remap-datatype money! "mn")
    (remap-datatype binary! "bi")

    ; there is no "to-none" operation in Rebol, all other datatypes have it...
    (remap-datatype/noconvert none! "nn")
    (remap-datatype/noconvert unset! "un")

    ;----------------------------------------------------------------------
    ; TYPE CONVERSION SHORTHANDS
    ; These are particularly common and there aren't many commands starting
    ; with T so aliasing them is useful.  May reconsider this later.  Also,
    ; these are special variations that add behaviors for types unsupported
    ; by Rebol's operators.
    ;----------------------------------------------------------------------

    t: :to
    tw: :to-word-mu
    tsw: :to-set-word
    ts: :to-string-mu
    tc: :to-char-mu
    tb: :to-block
    ti: :to-integer

    ;----------------------------------------------------------------------
    ; CONDITIONALS
    ;----------------------------------------------------------------------

    ;-- Rebol's IF is already two characters
    i: :if

    ei: :either
    e: :ei

    sw: :switch
    ca: :case ;-- should this be CS if CLOSURE is to be omitted?
    caa: :case/all

    ;----------------------------------------------------------------------
    ; LOOPING CONSTRUCTS
    ;----------------------------------------------------------------------

    lp: :loop
    l: :lp

    fe: :for-each
    f: :fe

    fr: :for
    ev: :every
    me: :map-each
    rme: :remove-each-mu
    fa: :forall
    fv: :forever

    wh: :while
    w: :wh

    ut: :until
    u: :ut

    cn: :continue
    br: :break
    tr: :trap
    ct: :catch
    am: :attempt

    qt: :quit

    ;----------------------------------------------------------------------
    ; DEFINING FUNCTIONS
    ;
    ; The behavior of FUNCTION and FUNC vs. CLOSURE and CLOS has to do with
    ; performance optimization, and ideally only the closure and clos
    ; semantics would exist.  Since performance is not the axis of concern
    ; for Rebmu, it goes with the more expressive construct (and so may
    ; Rebol3 at some point)
    ;----------------------------------------------------------------------

    fn: :function-mu

    dz: :does

    ;----------------------------------------------------------------------
    ; OBJECTS AND CONTEXTS
    ;----------------------------------------------------------------------
    us: :use
    ob: :object

    ;----------------------------------------------------------------------
    ; SERIES OPERATIONS
    ;----------------------------------------------------------------------

    po: :poke
    pc: :pick
    ap: :append
    apo: :append/only
    is: :insert ; IN is a keyword
    iso: :insert/only
    isp: :insert/part
    ispo: :insert/part/only
    tk: :take
    mno: :minimum-of
    mxo: :maximum-of
    se: :select
    rv: :reverse
    sl: :split

    ;-- note that Rebol uses RM for a DELETE alias, that's not very useful
    ;-- if anything in the box RM should be a shorthand for it's Rebol's
    ;-- notion of REMOVE, not Unix's.  Overriding in an act of protest...
    ;--    --Dr. Rebmu
    rm: :remove

    rp: :replace ;-- REPEND and REPEAT deprecated in Rebmu
    rpa: :replace/all
    rpac: :replace/all/case
    rpat: :replace/all/tail
    rpact: :replace/all/case/tail

    hd: :head
    tl: :tail
    bk: :back-mu
    nx: :next-mu
    ch: :change
    chp: :change/part
    sk: :skip
    fi: :find
    fio: :find/only
    fis: :find/skip
    uq: :unique
    pa: :parse-mu
    pp: :pre-parse-mu

    ln: :length

    os: :offset-of ;-- being a real word, OF might get used in the language
    ix: :index-of
    ty: :type-of
    t?: :tail?
    h?: :head?
    m?: :empty?
    v?: :value?

    fs: :first ; FR might be confused with fourth
    sc: :second
    th: :third
    fh: :fourth ; FR might be confused with first
    ff: :fifth
    sx: :sixth
    sv: :seventh
    eh: :eighth ; EI is either, and EG is either-greater
    nh: :ninth
    tt: :tenth
    ls: :last ; override LS list directory?  We need shell dialect

    ;----------------------------------------------------------------------
    ; PORTS
    ;----------------------------------------------------------------------

    del: :delete ; If shipping in console, why not use the matching term?
    dl: :delete ; Corresponding to the act of protest of changing RM

    ;----------------------------------------------------------------------
    ; METAPROGRAMMING
    ;----------------------------------------------------------------------

    co: :compose
    cod: :compose/deep
    mo: :mush-and-mold-compact
    jn: :join
    re: :reduce
    rj: :rejoin
    cl: :collect-mu
    lda: :load/all

    qo: :quote
    q: :qo

    ;----------------------------------------------------------------------
    ; MATH AND LOGIC OPERATIONS
    ;----------------------------------------------------------------------

    ad: :add-mu
    sb: :subtract-mu
    mp: :multiply
    dv: :div-mu
    dd: :divide
    ng: :negate-mu
    z?: :zero?
    md: :mod
    e?: :equal?

    lg10: :log-10
    lg2: :log-2
    ;-- is L2: LG2 worth it, or L+digit be used for something else?
    lge: :log-e ;-- can't do "(L)og (N)atural" as LN, due to LN: LENGTH-OF
    ;-- is LE: LGE worth it, or is LE better used or something else?
    lg: :lg10 ;-- Rebmu's 10-fingered-human bias, also shortens LG10 more

    ; ** is the infix power operator, but infix is sometimes not what you
    ; want so Rebol also has power as a prefix variant
    pw: :power

    ; CONDITIONAL LOGIC
    ;
    ; There may be a slight desire to use abbreviated infix logic, as it would
    ; cause a different evaluation ordering which might be desirable to have
    ; at no extra character cost.  But OR is already a 2-letter word, and XOR
    ; and AND are only 3-letter.  So it's probably better to save AN/AD for
    ; other purposes (XO/XR less useful...)

    ;-- NT is prefix NOT (itself an alias for NOT?), we took N? for NEGATIVE?
    a?: :and?
    o?: :or?
    x?: :xor?


    ; BITWISE
    ;
    ; These operators are the generalized ones, laid out for the day when
    ; AND/OR/XOR become "conditional"...they work on bitsets etc.
    ;
    ; http://curecode.org/rebol3/ticket.rsp?id=1879

    cm: :complement
    ic: :intersect
    un: :union
    df: :difference


    ev?: :even?
    op?: :odd?
    ++: :increment-mu
    --: :decrement-mu
    g?: :greater?
    ge?: :greater-or-equal?
    l?: :lesser?
    le?: :lesser-or-equal?
    se?: :strict-equal?
    n?: :negative?
    p?: :positive?
    sg: :sign-of
    y?: :true?
    n?: func [val] [not true? val] ; can be useful
    mn: :min
    mx: :max
    ay: :any
    al: :all

    ; to-integer (TI) always rounds down.  A "CEIL" operator is useful,
    ; though it's a bit verbose in Rebol as TO-INTEGER ROUND/CEILING VALUE.
    ; May be common enough in Code Golf math to warrant inclusion.
    ce: :ceiling-mu

    ;----------------------------------------------------------------------
    ; CONVERTERS
    ;----------------------------------------------------------------------

    ; Converters end in "-", so for instance "em-" is equivalent to
    ; TO-EMAIL.  I decided that minus signs on the end would indicate
    ; conversions because this is one place where default Rebol functions
    ; use a lot of hyphens.  The general goal of these functions is
    ; unlike modifiers, to not change their inputs.  It might be nice
    ; to have some

    ;----------------------------------------------------------------------
    ; INPUT/OUTPUT
    ;----------------------------------------------------------------------

    pr: :print
    p: :pr

    rd: :read
    wr: :write
    pb: :probe

    ri: :readin-mu
    r: :ri

    rl: :read/lines
    nl: :newline

    ;----------------------------------------------------------------------
    ; STRINGS
    ;----------------------------------------------------------------------
    tm: :trim
    tmt: :trim/tail
    tmh: :trim/head
    tma: :trim/all
    up: :uppercase
    upp: :uppercase/part
    lw: :lowercase
    lwp: :lowercase/part

    ;----------------------------------------------------------------------
    ; CONSTRUCTION FUNCTIONS
    ; Letter and a tilde means "factory".  This convention is not in Rebol
    ; but I thought that even if AR and AI were available for ARRAY and
    ; ARRAY/INITIAL the use of the tilde would allow the pattern to
    ; continue for some other things which *would* collide.
    ;
    ; This used to be done with carets, but Christopher Ross-Gill thought
    ; tildes looked better.
    ;----------------------------------------------------------------------

    cp: :copy
    c: :CP

    mk: :make
    cpd: :copy/deep
    cpp: :copy/part
    cppd: :copy/part/deep

    a~: :array
    ai~: :array/initial
    b~: does [copy []] ; two chars cheaper than cp[]
    h~: :to-http-url-mu
    hs~: :to-http-url-mu/secure
    i~: :make-integer-mu
    m~: :make-matrix-mu
    s~: does [copy ""] ; two chars cheaper than cp""
    si~: :make-string-initial-mu

    ;----------------------------------------------------------------------
    ; MISC
    ;----------------------------------------------------------------------

    as: :also
    nn: :none
    st: :set
    gt: :get

    en: :encode
    swp: :swap-exchange-mu
    fm: :format
    ;os: :onesigned-mu
    sp: :space

    ws: :whitespace
    dg: :digit
    dgh: :digit/hex
    dghu: :digit/hex/uppercase
    dghl: :digit/hex/lowercase
    dgb: :digit/binary
    lt: :letter
    ltu: :letter/latin/uppercase
    ltl: :letter/latin/lowercase

    ;----------------------------------------------------------------------
    ; MICRO MATH
    ;
    ; These can be overridden, but are helpful because mushing tries not to
    ; overload single-symbol/digit terminal semantics, in favor of giving us
    ; things like +a and a+.  We should automatically generate these for all
    ; single digits, although figuring out special meanings for a0, s0, m0,
    ; d1 etc. would be a good idea.

    e0: func [value] [value == 0]
    e1: func [value] [value == 1]
    e2: func [value] [value == 2]
    ; ...
    e9: func [value] [value == 9]

    a1: func [value] [add-mu value 1]
    a2: func [value] [add-mu value 2]
    ; ...

    s1: func [value] [subtract-mu value 1]
    s2: func [value] [subtract-mu value 2]
    ; ...

    d2: func [value] [divide value 2]
    ; ...

    m2: func [value] [multiply value 2]
    m3: func [value] [multiply value 3]
    ; ...

    p2: func [value] [value ** 2]
    ; ...

    ;----------------------------------------------------------------------
    ; PREFIX PLUS
    ;
    ; These operations work particularly well as the source of an assignment
    ; because of the way that unmushing turns [A+b] into [a: +b]
    ;
    ; Haven't defined them yet... what will this family do?

    ;----------------------------------------------------------------------
    ; POSTFIX PLUS
    ;
    ; These are not easy to assign to in mushed code, because the bias
    ; gives the symbol to the next word e.g. [A+b] => [a: +b] instead of
    ; [a+: b].
    ;
    ; Idea is that these modify their arguments to save you from situations
    ; where you might otherwise have to make things the target of an assignment,
    ; like [M: ADD M 2].  Shorter code with a+M2 than Ma+M2, and you also
    ; are less likely to cause a mushing break.  Note that the plus doesn't
    ; mean "advance" or "add" in this context, LAST+ is actually an
    ; operator which traverses the series backwards.

    a+: :add-modify-mu
    f+: :first+
    s+: :subtract-modify-mu
    n+: :next-modify-mu
    b+: :back-modify-mu

    ; How strange could we get?  Is it useful to do [Z: EQUALS? Z 3] on any
    ; kind of regular basis?  Maybe if you do that test often after but
    ; don't need the value
    =+: :equal-modify-mu

    ; what about two character functions?  can they return different
    ; things than their non-modifier counterparts?
    ch+: :change-modify-mu
    hd+: :head-modify-mu
    tl+: :tail-modify-mu
    sk+: :skip-modify-mu


    ;----------------------------------------------------------------------
    ; REDEFINING HELPER
    ;
    ; While many of the original code-golf specific aspects of Rebmu that
    ; were imagined were kicked out as useless (as say, compared to throwing
    ; in a mushed matrix library etc.) this one is still around for study.
    ; The idea was a dot operator to be helpful for quickly redefining symbols
    ; used repeatedly.
    ;
    ;     .[aBCdEF] => .[a bc d ef] => a: :bc d: :ef
    ;
    ; If you noticed an unusual repeated need for a function you could throw
    ; that in.  Considering the minimal case of .[aBC] it's 6 characters, which
    ; is the same count as `A: :bc` would be.  However,  you wind up at a
    ; close bracket that starts a new mushing point, so it saves on what would
    ; be a necessary trailing space.  If it's the first thing in your program
    ; you don't have to worry about the dot getting picked up as a word
    ; character, despite its "stickiness" in words

    rf: :redefine-mu
    .: :rf


    ; REVIEW: what kinds of meanings might be given to prefix question mark?
]

rebmu: function [
    {Visit http://hostilefork.com/rebmu/}

    code "The Rebmu or Rebol code"
        [text! block! file! url!]
    /args "argument A, unless block w/set-words; can be Rebmu format [X10Y20]"
        [any-value!]
    /nocopy "Disable the default copy/deep of arguments for safety"
    /stats "Print out some statistical information"
    /debug "Output debugging information"
    /env "Return runnable object plus environment without executing main"
    /inject "Run some test code in the environment after main function"
        [block! text!]

    <static>
    context (~unset~)
][
    case [
        text? code [
            if stats [
                print ["Input Rebmu string was:" length of code "characters."]
            ]
            code: load code
        ]

        any [
            file? code
            url? code
        ][
            code: load code

            all [
                'Rebmu = first code
                block? second code
            ] then [
                ; ignore the header for the moment... just pick offset
                ; the first two values from code
                take code
                take code
            ] else [
                print "WARNING: Rebmu sources should start with Rebmu [...]"

                ; Keep running, hope the file was valid Rebmu anyway
            ]
        ]

        block? code [
            if stats [
                print "NOTE: Pass in Rebmu as string, not a block."
                print "(That will give you a canonical character count.)"
            ]
        ]
    ] else [
        fail "Bad code parameter."
    ]

    ensure block! code

    code: my unmush

    if debug [
        print ["Executing:" mold code]
    ]

    if stats [
        print [
            "Rebmu as mushed Rebol block molds to:"
            length of mold/only code
            "characters."
        ]
    ]

    === UNMUSH CODE INJECTION, DEFAULT TO EMPTY BLOCK ===

    inject: default [copy []]
    if text? inject [
        inject: load inject
    ]
    if not block? inject [
        code: to block! inject
    ]
    inject: my unmush

    === UNMUSH ARGUMENT FOR ARGUMENT CODE INJECTION, DEFAULT TO EMPTY BLOCK ===

    either args [
        either block? args [
            args: unmush either nocopy [args] [copy/deep args]
            if not set-word? first args [
                ; assign to a if the block doesn't start with a set-word
                args: compose [a: (args)]
            ]
        ][
            args: compose [a: (args)]
        ]
    ][
        args: copy []
    ]

    ; see https://github.com/hostilefork/rebmu/issues/7
    ; We track the outermost Rebmu context via a variable in the user context.
    ; This allows us to effectively create a "new" user context holding all
    ; the Rebmu overrides.

    outermost: unset? 'context

    if outermost [
        context: copy rebmu-base-context
        append context args

        ; Rebmu's own behavior replaces DO, no /NEXT support yet
        extend context 'do func [value] [
            either string? value [
                rebmu value
            ][
                do value
            ]
        ]

        ; When we load, we want default binding to override with this context
        ; over system.contexts.user

        rebmu-load: func [source] [
            bind load source context
        ]

        extend context 'load :rebmu-load
        extend context 'ld :rebmu-load

        ; Add LOAD-VALUE (LV) ?
    ]

    bind code context
    bind inject context

    if env [  ; only asked for the environment (e.g. to debug it)
        return context
    ]

    let [error result]: trap [
        do inject
        do code
    ]

    ; If we exit the last "Rebmu user" context, then clear it
    if outermost [
        context: ~unset~
    ]

    if error [
        fail error
    ]

    return get/any 'result
]

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
    Type: module
    Name: Rebmu
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

        The . character was once available but was taken for TUPLE!.
        The & character was also once available, but reserved for future use.

        ~ is generally not legal in WORD! as it is used to denote BAD-WORD!
        but the single character ~ is available to be overridden.  Its default
        behavior is to create an ~unset~ isotope, which may not sound useful in
        code golf but constructs might decide to treat it in an "unusual" way
        e.g. to opt out of taking any branch in a conditional.

        ?
        |
        a  ; usually a program argument or a-function variable
        b
        c => copy
        d
        e => else
        f => for  ; now more generic
        g
        h
        i => if
        j
        k
        l => let
        m => match
        n
        o
        p => print
        q => quote
        r => return  ; only applies in functions, if not in function will QUIT
        s
        t => to  ; variants like TSW for TO-SET-WORD trumps T for THEN
        u => until
        v
        w => while  ; TBD
        x
        y
        z


        ### EXISTING TWO-CHARACTER SPACE

        Because there are only so many single characters (unless you start
        using Unicode...) the majority of Rebmu function definitions live
        in the two-character space.  However, refinements follow a system...
        so even if it would be *possible* to do APPEND/DUP => AD, such
        compression tricks are seen as less consistent than if you have
        APPEND => AP and APPEND/DUP => APD.  So the two-character space
        is the baseline for growing further in a systemic way.

        Yet Rebol itself does define a few things already in the two character
        space that should not be overridden, to reach Rebmu's goal of being
        able to compatibly run any all-lowercase Rebol code in midstream.
        Here's a short study of the space used.

        Very Reasonable Use of English Words

            TO    to conversion
            AS    aliasing operator
            OR    or operator (infix)
            IN    word or block in the object's context
            IF    conditional if
            DO    evaluates a block, file, url, function word
            AT    returns the series at the specified index
            NO    logic false
            ON    logic true
            SO    postfix assert (2 = 1 + 1 so print "math works")
            AN    english pluralize (an "axe" -> "an axe", an "cat" -> "a cat")
            ME    self-reference after set word (variable: me + 1)
            MY    variant of ME for non-enfix (block: my append 10)
            BE    (unused)
            BY    (unused)

        Reasonably non-controversial use of Symbolic Operators

            >=    true if the first value is greater than the second (infix)
            <=    true if the first value is less than the second (infix)
            !=    true if the values are not equal (infix)
            <>    same function as != despite looking like empty tag
            ->    lambda function (`x -> [print x]` is `func [x] [print x]`)
            <-    pointfree function (`<- append b` is `func [x] [append b x]`)

        Debug use of "drawing-looking" operators that pop off the page (their
        non-English appearance makes them preferable for this purpose instead
        of quirkier things like "-- decrements variables")

            --    debug dump following variable name and its value
            **    comment line out
            !!    breakpoint
            ++    (unused)
            ==    section header (TBD, currently strict equality)
            ??    Debug probe a word, path, block or such

        Unapplied in Rebol but used in Red for questionable benefit; these are
        likely to take on some kind of larger systemic purpose, possibly as
        console DSL operations:

            <<    infix version of prefix shift left
            >>    infix version of prefix shift right

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

        Several more options were opened up in the two character space by the
        so-called "arrow words".  They are things like |> and >< etc.  These
        have experiments but nothing settled down completely.

        There are tricks for `/` acting like a WORD! even though it is actually
        a path.  That opens up some potential space for `//`, `/.`, `./` and
        `..` as being operations, but this concept has not been explored.


        ### SINGLE CHARACTER PLUS QUESTION MARK

        Several of these freed up with the requirement that ending in a ?
        actually return a LOGIC!.  The useful function empty? doesn't fit
        if E? is EQUAL? and EM? is EMAIL?

        A? => and?
        B?  ; could be... block?
        C?  ; could be... char?
        D? => distinct?
        E? => equal?
        F?
        G? => greater?
        H? => head?
        I?  ; could be... integer?
        J?
        K?
        L? => lesser?
        M? => match?  ; MM? is mismatch.
        N? => negative?
        O? => or?
        P? => positive?
        Q?
        R?
        S? => same?
        T? => tail?  ; can't be TRUE?, TAIL? is more important
        U? => unequal?
        V? => value?
        W?
        X? => xor?
        Y? => true?  ; (a.k.a. yes?)
        Z? => zero?
    }
]

; Load the modules implementing mush/unmush

import %mush.reb
import %unmush.reb


; Load the library of xxx-mu functions; tricks that are specific to Rebmu
; and would not seriously find their way into Rebol/Red mainline
;
; NOTE: While originally there was a tendency to be liberal with these,
; they are being excised as they can sort of be seen as interfering with
; Rebmu's main mission, which is to teach/evangelize Rebol dialecting.
; A trick just for the sake of helping win code golf that does not really
; assist with that (or worse, inhibits learning the languages proper)
; should be included sparingly--if at all

import %mulibrary.reb


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

    (remap-datatype action! "ac")
    (remap-datatype block! "bl")
    ; CHAR! is a "fake type" (meta word), review
    (remap-datatype decimal! "dc")
    (remap-datatype email! "em")
    (remap-datatype error! "er")
    (remap-datatype get-word! "gw")
    (remap-datatype group! "gr")
    (remap-datatype integer! "in")
    (remap-datatype pair! "pr")
    (remap-datatype percent! "pc")
    (remap-datatype logic! "lc")
    (remap-datatype map! "mp")
    (remap-datatype object! "ob")
    (remap-datatype path! "pa")
    ; LIT-WORD! is a "fake type" (meta word), review
    ; REFINEMENT! is a "fake type" (meta word), review
    (remap-datatype time! "tm")
    (remap-datatype tuple! "tu")
    (remap-datatype text! "tx")
    (remap-datatype file! "fi")
    (remap-datatype word! "wd")
    (remap-datatype tag! "tg")
    (remap-datatype money! "mn")
    (remap-datatype binary! "bi")

    ; there is no "to-blank" operation in Rebol, all other datatypes have it...
    (remap-datatype/noconvert blank! "bn")

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
    tt: :to-text-mu
    tc: :to-char-mu
    tb: :to-block
    ti: :to-integer

    ;----------------------------------------------------------------------
    ; DEFINING FUNCTIONS
    ;
    ; Note: This is done first because its used in later definitions.
    ;
    ; The behavior of FUNCTION and FUNC vs. CLOSURE and CLOS has to do with
    ; performance optimization, and ideally only the closure and clos
    ; semantics would exist.  Since performance is not the axis of concern
    ; for Rebmu, it goes with the more expressive construct (and so may
    ; Rebol3 at some point)
    ;----------------------------------------------------------------------

    fn: :function-mu

    ds: :does

    ; DX is a variadic branch builder, delegated to by most constructs that
    ; want to be able to "do more" than just a branch.
    ;
    dx: func [:args [<opt> any-value! <variadic>]] [
        a: take args
        if block? a [return does a]
        if word? a [
            ; !!! TBD
        ]
    ]
    d: :dx

    ; Function dialects in Rebmu employ a method of quoting their arguments
    ; literally.  If not blocks, they are read as *instructions* for what spec
    ; or body to build.  It is a compact dialect for function construction.
    ;
    fq: :funqtion-mu

    ; FX is a particularly tweaked version of FQ that pulls from a list of
    ; helpful memoizations of names for args and locals.  It's designed to
    ; not stomp on common abbreviations like I for IF.
    ;
    ; !!! To be written...
    ;
    fx: :fq

    f: :fx

    ;----------------------------------------------------------------------
    ; CONDITIONALS
    ;----------------------------------------------------------------------

    ; Conditionals in Rebmu are less conservative than in Rebol.  They are
    ; willing to handle non-BLOCK! and non-FUNCTION! branches, returning the
    ; values as-is.  For why this is not done in general, see:
    ;
    ; https://forum.rebol.info/t/backpedaling-on-non-block-branches/476
    ;
    ; !!! Should they also take isotope forms and treat them as false or pass
    ; them through without running any brances?

    if: :if-mu
    i: :if

    either: :either-mu
    ei: :either

    un: adapt :if [condition: not to-value :condition]

    es: :else
    e: :es

    th: :then

    ao: :also  ; AS is a valid language keyword, AL is ALL

    sw: :switch
    cs: :case
    csa: :case/all


    ;----------------------------------------------------------------------
    ; LOOPING CONSTRUCTS
    ;----------------------------------------------------------------------

    lp: :loop  ; L is LET

    fe: :for-each

    fr: :for  ; !!! FOR-MU to tolerate more options, so `f x 10 [...]` works
    f: :fr

    ev: :every
    me: :map-each
    rme: :remove-each-mu
    cy: :cycle

    rp: :repeat  ; R is RETURN inside a function (globally R acts as QUIT)

    ; More valuable to have a single character looping construct take U than
    ; to have UNLESS take it.
    ;
    ut: :until
    ux: macro [] [[until dx]]
    u: :ux

    uz: macro [] [[until .zero?]]
    ue: macro [] [[until .equal?]]
    ul: macro [] [[until .lesser?]]
    ug: macro [] [[until .greater?]]

    cn: :continue
    br: :break  ; BK is BACK
    tr: :trap
    ct: :catch
    am: :attempt

    qt: :quit
    r: :qt  ; inside functions, R is return; this is done to save Q for quote

    ;----------------------------------------------------------------------
    ; OBJECTS AND CONTEXTS
    ;----------------------------------------------------------------------

    lt: :let
    l: :lt

    us: :use
    ob: specialize :make [type: object!]

    ;----------------------------------------------------------------------
    ; SERIES OPERATIONS
    ;----------------------------------------------------------------------

    po: :poke
    pc: :pick
    ap: :append
    ir: :insert  ; IN, IS, IT are standalone words
    irp: :insert/part
    ird: :insert/part/dup
    tk: :take
    mno: :minimum-of
    mxo: :maximum-of
    se: :select
    rv: :reverse
    sl: :split

    rm: :remove

    rl: :replace  ; RP is repeat, REPEND is deprecated in Ren-C
    rla: :replace/all
    rlac: :replace/all/case
    rlat: :replace/all/tail
    rlact: :replace/all/case/tail

    hd: :head
    tl: :tail
    bk: :back-mu
    nx: :next-mu
    ch: :change
    chp: :change/part
    sk: :skip
    fi: :find
    fis: :find/skip
    uq: :unique
    pa: :parse-mu
    pp: :pre-parse-mu

    ln: specialize :reflect [property: 'length]

    os: :offset-of  ; OF is used in the language
    ix: :index-of
    ty: specialize :reflect [property: 'type]
    t?: :tail?
    h?: :head?
    m?: :empty?
    v?: :value?

    fs: :first  ; FR might be confused with fourth
    sc: :second
    th: :third
    fh: :fourth ; FR might be confused with first
    ff: :fifth
    sx: :sixth
    sv: :seventh
    eh: :eighth  ; EI is either, and EG is either-greater
    nh: :ninth
    tt: :tenth
    ls: :last  ; override LS list directory?  We need SHELL dialect

    ;----------------------------------------------------------------------
    ; PORTS
    ;----------------------------------------------------------------------

    del: :delete  ; If shipping in console, why not use the matching term?
    dl: :delete  ; Corresponding to the act of protest of changing RM

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

    qo: :quote  ; QU is QUIT
    q: :qo  ; more useful to abbreviate further than Q for QUIT

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
    ; is L2: LG2 worth it, or L+digit be used for something else?
    lge: :log-e  ; can't do "(L)og (N)atural" as LN, due to LN: LENGTH-OF
    ; is LE: LGE worth it, or is LE better used or something else?
    lg: :lg10  ; Rebmu's 10-fingered-human bias, also shortens LG10 more

    ; POW is the infix power operator, but infix is sometimes not what you
    ; want so Rebol also has power as a prefix variant.
    pw: :power

    ; CONDITIONAL LOGIC
    ;
    ; There may be a slight desire to use abbreviated infix logic, as it would
    ; cause a different evaluation ordering which might be desirable to have
    ; at no extra character cost.  But OR is already a 2-letter word, and XOR
    ; and AND are only 3-letter.  So it's probably better to save AN/AD for
    ; other purposes (XO/XR less useful...)

    ; NT is prefix NOT (itself an alias for NOT?), we took N? for NEGATIVE?
    a?: :and?
  ; o?: :or?  ; !!! Does not exist, needs to be added
  ; x?: :xor?  ; !!! same


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
    od?: :odd?
    inc: :increment-mu
    ic: :inc
    dec: :decrement-mu
    dc: :dec
    g?: :greater?
    ge?: :greater-or-equal?
    l?: :lesser?
    le?: :lesser-or-equal?
    se?: :strict-equal?
    n?: :negative?
    p?: :positive?
    sg: :sign-of
    y?: :did
    n?: :not
    mn: :min
    mx: :max

    ; The void-tolerating forms are more useful
    ay: :any  ; AN is its own word
    al: :all

    ; to-integer (TI) always rounds down.  A "CEIL" operator is useful,
    ; though it's a bit verbose in Rebol as TO-INTEGER ROUND/CEILING VALUE.
    ; May be common enough in Code Golf math to warrant inclusion.
    ;
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
    wrs: :write-stdout ;-- was PRINT/ONLY
    pb: :probe

    ri: :readin-mu
    r: :ri

    rl: :read/lines
    nl: :newline  ; already abbreviated as LF for line feed (?)

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

    mk: :make

    cp: :copy
    c: :cp
    cpd: :copy/deep
    cpp: :copy/part
    cppd: :copy/part/deep

    ; !!! ~ became reserved for use with BAD-WORD!.
  ;  A~: :array
  ;  AI~: :array/initial
  ;  B~: does [copy []] ; two chars cheaper than cp[]
  ;  H~: :to-http-url-mu
  ;  HS~: :to-http-url-mu/secure
  ;  I~: :make-integer-mu
  ;  M~: :make-matrix-mu
  ;  S~: does [copy ""] ; two chars cheaper than cp""
  ;  SI~: :make-string-initial-mu

    ;----------------------------------------------------------------------
    ; MISC
    ;----------------------------------------------------------------------

    bn: :blank
    st: :set
    gt: :get

    en: :encode
    swp: :swap-exchange-mu
    fm: :format
  ; os: :onesigned-mu
    sp: :space

    ; !!! Predefined character sets are something that has never been fully
    ; worked out or worked through.  They were in the "proposals" module but
    ; that has been removed.  New ideas for BITSET! implementation would allow
    ; sparse character sets in Unicode at lower cost.
    ;
  comment [
    ws: :whitespace
    dg: :digit
    dgh: :digit/hex
    dghu: :digit/hex/uppercase
    dghl: :digit/hex/lowercase
    dgb: :digit/binary
    lt: :letter
    ltu: :letter/latin/uppercase
    ltl: :letter/latin/lowercase
  ]

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
    ; like [m: add m 2].  Shorter code with a+M2 than Ma+M2, and you also
    ; are less likely to cause a mushing break.  Note that the plus doesn't
    ; mean "advance" or "add" in this context, LAST+ is actually an
    ; operator which traverses the series backwards.

 ;   a+: :add-modify-mu
 ;   f+: :first+
 ;   s+: :subtract-modify-mu
 ;   n+: :next-modify-mu
 ;   b+: :back-modify-mu

    ; How strange could we get?  Is it useful to do [Z: EQUALS? Z 3] on any
    ; kind of regular basis?  Maybe if you do that test often after but
    ; don't need the value
    ;
    =+: :equal-modify-mu

    ; what about two character functions?  can they return different
    ; things than their non-modifier counterparts?
    ;
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
    ; The idea was an operator to be helpful for quickly redefining symbols
    ; used repeatedly.
    ;
    ;     rf[aBCdEF] => rf[a bc d ef] => a: :bc d: :ef
    ;
    ; If you noticed an unusual repeated need for a function you could throw
    ; that in.  Considering the minimal case of rf[aBC] it's 7 characters, which
    ; is one more than `A: :bc` would be.  However, you wind up at a
    ; close bracket that starts a new mushing point, so it saves on what would
    ; be a necessary trailing space.

    rf: :redefine-mu


    ; REVIEW: what kinds of meanings might be given to prefix question mark?
]

export rebmu: function [
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

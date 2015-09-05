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

    History: [
        0.1.0 [10-Jan-2010 {Sketchy prototype written to cover only the
        Roman Numeral example I worked through when coming up with the
        idea.  So very incomplete, more a proof of concept.}]

        0.2.0 [22-Jun-2010 {Language more complete, includes examples.
        Ditched concept of mushing symbols like + and - into single
        character operators is removed due to realization that A+
        B+ C+ etc. are more valuable in the symbol space than one
        character for AD.}]

        0.3.0 [24-Jun-2010 {Made backwards compatible with Rebol 2.
        Note that things like CN for continue or PERCENTAGE! datatype
        were added in Rebol 3.  You can use these in your Rebmu programs
        but they will only work if using Rebmu with an r3 interpreter.
        Also did several name tweaks like instead of AA for AND~ it's
        now A~ along with other consistencies.}]

        0.5.0 [16-Feb-2014 {Version bump to indicate growing maturity
        of the language.  Abandon Rebol 2 support.  Rebmu files now
        have proper Rebol ecology headers.}]

        0.6.0 [6-Apr-2014 {Large cleanup creating incompatibility with
        most all previous Rebmu code solutions.  Examples have been updated
        in GitHub.  Major theme was removing the custom IF/UNLESS/EITHER
        implementation and some clearer names.}]

        0.7.0 [15-Sep-2015 {Project revisited to incorporate new ideas and
        decisions from the Ren/C effort.  Incorporates the rebol-proposals
        module to work with experimental language features instead of
        having its own "incubator" project.  "Mu library" features removed
        in favor of embracing the language default more closely.}]
    ]
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
remap-datatype: function [type [datatype!] shorter [string!] /noconvert] [
    stem: head remove back tail to-string to-word type
    result: reduce [
        load rejoin [shorter "!" ":"] load rejoin [":" stem "!"]
        load rejoin [shorter "?" ":"] load rejoin [":" stem "?"]
    ]
    unless noconvert [
        append result reduce [
            load rejoin [shorter "-" ":"] load rejoin [":" "to-" stem]
        ]
    ]
    bind result system/contexts/user
]


; A rebmu wrapper lets you wrap a refinement
; need to write generalization of spec capture with reflect, e.g.
; spec: reflect :arg 'spec
rebmu-wrap: function [refined [path!] args [block!]] [
    func args compose [
        (refined) (args)
    ]
]


rebmu-base-context: object compose [

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

    T: :TO
    TW: :to-word-mu
    TSW: :to-set-word
    TS: :to-string-mu
    TC: :to-char-mu
    TB: :to-block
    TI: :to-integer

    ;----------------------------------------------------------------------
    ; CONDITIONALS
    ;----------------------------------------------------------------------

    ;-- Rebol's IF is already two characters
    I: :if
    IFO: rebmu-wrap 'if/only [condition true-branch]
    IO: :IFO

    EI: :either
    E: :EI
    EIO: rebmu-wrap 'either/only [condition true-branch false-branch]
    EO: :EIO

    SW: :switch
    CA: :case ;-- should this be CS if CLOSURE is to be omitted?
    CAA: rebmu-wrap 'case/all [block]

    UL: :unless
    U: :UL
    ULO: :rebmu-wrap 'unless/only [condition false-branch]
    UO: :ULO

    ;----------------------------------------------------------------------
    ; LOOPING CONSTRUCTS
    ;----------------------------------------------------------------------

    LP: :loop
    L: :LP

    FE: :for-each
    F: :FE

    FR: :for
    EV: :every
    ME: :map-each
    RME: :remove-each-mu
    FA: :forall
    FV: :forever

    WH: :while
    W: :WH
    WA: :rebmu-wrap 'while/after [cond-block body-block]

    ; single-character U taken for UNLESS 
    UT: :until
    UTA: rebmu-wrap 'until/after [cond-block body-block]

    CN: :continue
    BR: :break
    BRW: rebmu-wrap 'break/with [value]
    TR: :trap
    CT: :catch
    AM: :attempt

    QT: :quit
    QTW: rebmu-wrap 'quit/with [value]

    ;----------------------------------------------------------------------
    ; DEFINING FUNCTIONS
    ;
    ; The behavior of FUNCTION and FUNC vs. CLOSURE and CLOS has to do with
    ; performance optimization, and ideally only the closure and clos
    ; semantics would exist.  Since performance is not the axis of concern
    ; for Rebmu, it goes with the more expressive construct (and so may
    ; Rebol3 at some point)
    ;----------------------------------------------------------------------

    FN: :closure
    FC: :clos
    
    DZ: :does
    &: :DZ

    DF: :does-function-mu
    |: :DF

    a|: :function-a-mu
    b|: :function-ab-mu
    c|: :function-abc-mu
    d|: :function-abcd-mu
    z|: :function-z-mu
    y|: :function-zy-mu
    x|: :function-zyx-mu
    w|: :function-zyxw-mu
    ; TODO: Write generator?
    a&: :func-a-mu
    b&: :func-ab-mu
    c&: :func-abc-mu
    d&: :func-abcd-mu
    z&: :func-z-mu
    y&: :func-zy-mu
    x&: :func-zyx-mu
    w&: :func-zyxw-mu
    RT: :return

    ;----------------------------------------------------------------------
    ; OBJECTS AND CONTEXTS
    ;----------------------------------------------------------------------
    US: :use
    OB: :object

    ;----------------------------------------------------------------------
    ; SERIES OPERATIONS
    ;----------------------------------------------------------------------

    PO: :poke
    PC: :pick
    AP: :append
    APO: rebmu-wrap 'append/only [series value]
    IS: :insert ; IN is a keyword
    ISO: rebmu-wrap 'insert/only [series value]
    ISP: rebmu-wrap 'insert/part [series value limit]
    ISPO: rebmu-wrap 'insert/part/only [series value limit]
    TK: :take
    MNO: :minimum-of
    MXO: :maximum-of
    SE: :select
    RV: :reverse
    SL: :split

    ;-- note that Rebol uses RM for a DELETE alias, that's not very useful
    ;-- if anything in the box RM should be a shorthand for it's Rebol's
    ;-- notion of REMOVE, not Unix's.  Overriding in an act of protest...
    ;--    --Dr. Rebmu
    RM: :remove

    RP: :replace ;-- REPEND and REPEAT deprecated in Rebmu 
    RPA: rebmu-wrap 'replace/all [target search rep]
    RPAC: rebmu-wrap 'replace/all/case [target search rep]
    RPAT: rebmu-wrap 'replace/all/tail [target search rep]
    RPACT: rebmu-wrap 'replace/all/case/tail [target search rep]

    HD: :head
    TL: :tail
    BK: :back-mu
    NX: :next-mu
    CH: :change
    CHP: rebmu-wrap 'change/part [series value size]
    SK: :skip
    FI: :find
    FIO: rebmu-wrap 'find/only [series value]
    FIS: rebmu-wrap 'find/skip [series value size]
    UQ: :unique
    PA: :parse-mu
    PP: :pre-parse-mu

    LN: :length

    OS: :offset-of ;-- being a real word, OF might get used in the language
    IX: :index-of
    TY: :type-of
    T?: :tail?
    H?: :head?
    M?: :empty?
    V?: :value?

    FS: :first ; FR might be confused with fourth
    SC: :second
    TH: :third
    FH: :fourth ; FR might be confused with first
    FF: :fifth
    SX: :sixth
    SV: :seventh
    EH: :eighth ; EI is either, and EG is either-greater
    NH: :ninth
    TT: :tenth
    LS: :last ; override LS list directory?  We need shell dialect

    ;----------------------------------------------------------------------
    ; PORTS
    ;----------------------------------------------------------------------

    DEL: :delete ; If shipping in console, why not use the matching term?
    DL: :delete ; Corresponding to the act of protest of changing RM

    ;----------------------------------------------------------------------
    ; METAPROGRAMMING
    ;----------------------------------------------------------------------

    CO: :compose
    COD: rebmu-wrap 'compose/deep [value]
    MO: :mush-and-mold-compact
    JN: :join
    RE: :reduce
    RJ: :rejoin
    CL: :collect-mu
    LDA: rebmu-wrap 'load/all [source]
    CB: :combine
    CBW: rebmu-wrap 'combine/with [block delimiter]

    QO: :quote
    Q: :QO 

    ;----------------------------------------------------------------------
    ; MATH AND LOGIC OPERATIONS
    ;----------------------------------------------------------------------

    AD: :add-mu
    SB: :subtract-mu
    MP: :multiply
    DV: :div-mu
    DD: :divide
    NG: :negate-mu
    Z?: :zero?
    MD: :mod
    E?: :equal?

    LG10: :log-10
    LG2: :log-2
    ;-- is L2: LG2 worth it, or L+digit be used for something else?
    LGE: :log-e ;-- can't do "(L)og (N)atural" as LN, due to LN: LENGTH-OF
    ;-- is LE: LGE worth it, or is LE better used or something else? 
    LG: :LG10 ;-- Rebmu's 10-fingered-human bias, also shortens LG10 more

    ; ** is the infix power operator, but infix is sometimes not what you
    ; want so Rebol also has power as a prefix variant
    PW: :power

    ; CONDITIONAL LOGIC
    ;
    ; There may be a slight desire to use abbreviated infix logic, as it would
    ; cause a different evaluation ordering which might be desirable to have
    ; at no extra character cost.  But OR is already a 2-letter word, and XOR
    ; and AND are only 3-letter.  So it's probably better to save AN/AD for
    ; other purposes (XO/XR less useful...)

    ;-- NT is prefix NOT (itself an alias for NOT?), we took N? for NEGATIVE?
    A?: :and?
    O?: :or?
    X?: :xor?


    ; BITWISE
    ;
    ; These operators are the generalized ones, laid out for the day when
    ; AND/OR/XOR become "conditional"...they work on bitsets etc.
    ;
    ; http://curecode.org/rebol3/ticket.rsp?id=1879

    CM: :complement
    IC: :intersect
    UN: :union
    DF: :difference


    EV?: :even?
    OD?: :odd?
    ++: :increment-mu
    --: :decrement-mu
    G?: :greater?
    GE?: :greater-or-equal?
    L?: :lesser?
    LE?: :lesser-or-equal?
    SE?: :strict-equal?
    N?: :negative?
    P?: :positive?
    SG: :sign-of
    Y?: :true?
    N?: func [val] [not true? val] ; can be useful
    MN: :min
    MX: :max
    AY: :any
    AL: :all

    ; to-integer (TI) always rounds down.  A "CEIL" operator is useful,
    ; though it's a bit verbose in Rebol as TO-INTEGER ROUND/CEILING VALUE.
    ; May be common enough in Code Golf math to warrant inclusion.
    CE: :ceiling-mu

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

    PR: :print
    P: :PR 

    RD: :read
    WR: :write
    PRO: rebmu-wrap 'print/only [value]
    PB: :probe

    RI: :readin-mu
    R: :RI

    RL: rebmu-wrap 'read/lines [source]
    NL: :newline

    ;----------------------------------------------------------------------
    ; STRINGS
    ;----------------------------------------------------------------------
    TM: :trim
    TMT: rebmu-wrap 'trim/tail [series]
    TMH: rebmu-wrap 'trim/head [series]
    TMA: rebmu-wrap 'trim/all [series]
    UP: :uppercase
    UPP: rebmu-wrap 'uppercase/part [string length]
    LW: :lowercase
    LWP: rebmu-wrap 'lowercase/part [string length]

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

    CP: :copy
    C: :CP

    MK: :make
    CPD: rebmu-wrap 'copy/deep [value]
    CPP: rebmu-wrap 'copy/part [value]
    CPPD: rebmu-wrap 'copy/part/deep [value]

    A~: :array
    AI~: rebmu-wrap 'array/initial [size value]
    B~: does [copy []] ; two chars cheaper than cp[]
    H~: :to-http-url-mu
    HS~: rebmu-wrap 'to-http-url-mu/secure [:url]
    I~: :make-integer-mu
    M~: :make-matrix-mu
    S~: does [copy ""] ; two chars cheaper than cp""
    SI~: :make-string-initial-mu

    ;----------------------------------------------------------------------
    ; MISC
    ;----------------------------------------------------------------------

    AS: :also
    NN: :none
    ST: :set
    GT: :get

    EN: :encode
    SWP: :swap-exchange-mu
    FM: :format
    ;OS: :onesigned-mu
    SP: :space

    WS: :whitespace
    DG: :digit
    DGH: rebmu-wrap 'digit/hex []
    DGHU: rebmu-wrap 'digit/hex/uppercase []
    DGHL: rebmu-wrap 'digit/hex/lowercase []
    DGB: rebmu-wrap 'digit/binary []
    LT: :letter
    LTU: rebmu-wrap 'letter/latin/uppercase []
    LTL: rebmu-wrap 'letter/latin/lowercase []

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

    A+: :add-modify-mu
    F+: :first+
    S+: :subtract-modify-mu
    N+: :next-modify-mu
    B+: :back-modify-mu

    ; How strange could we get?  Is it useful to do [Z: EQUALS? Z 3] on any
    ; kind of regular basis?  Maybe if you do that test often after but
    ; don't need the value
    =+: :equal-modify-mu

    ; what about two character functions?  can they return different
    ; things than their non-modifier counterparts?
    CH+: :change-modify-mu
    HD+: :head-modify-mu
    TL+: :tail-modify-mu
    SK+: :skip-modify-mu


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

    RF: :redefine-mu
    .: :RF


    ; REVIEW: what kinds of meanings might be given to prefix question mark?
]

rebmu: function [
    {Visit http://hostilefork.com/rebmu/}
    code [file! url! block! string!] 
        {The Rebmu or Rebol code}
    /args arg [any-type!]
        {argument A, unless a block w/set-words; can be Rebmu format [X10Y20]}
    /nocopy
        {Disable the default copy/deep of arguments for safety}
    /stats
        {Print out some statistical information}
    /debug
        {Output debugging information}
    /env
        {Return runnable object plus environment without executing main}
    /inject injection [block! string!]
        {Run some test code in the environment after main function}
] [
    ; block is sneaky way to make a "static" variable
    statics: [
        context: #[none] ;-- none would not be reduced...
    ]

    case [
        string? code [
            if stats [
                print ["Original Rebmu string was:" length code "characters."]
            ]
            code: load code
        ]

        any [
            file? code
            url? code
        ] [
            code: load code

            either all [
                'Rebmu = first code
                block? second code
            ] [
                ;-- ignore the header for the moment... just pick offset
                ;-- the first two values from code
                take code
                take code
            ] [
                print "WARNING: Rebmu sources should start with Rebmu [...]"
                print "(See: http://curecode.org/rebol3/ticket.rsp?id=2105)"

                ;-- Keep running, hope the file was valid Rebmu anyway
            ]
        ]

        block? code [
            if stats [
                print "NOTE: Pass in Rebmu as string, not a block."
                print "(That will give you a canonical character count.)"
            ]
        ]

        true [
            print "Bad code parameter."
            quit
        ]
    ]

    unless block? code [
        code: compose/only [(code)]
    ]


    code: unmush (code)

    if debug [
        print ["Executing:" mold code]
    ]

    if stats [
        print [
            "Rebmu as mushed Rebol block molds to:"
            length mold/only code
            "characters."
        ]
    ]

    either inject [
        if string? injection [
            injection: load injection
        ]
        unless block? injection [
            code: to block! injection
        ]
        injection: unmush injection
    ] [
        injection: copy []
    ]

    either args [
        either block? arg [
            arg: unmush either nocopy [arg] [copy/deep arg]
            unless set-word? first arg [
                ; assign to a if the block doesn't start with a set-word
                arg: compose/only [a: (arg)]
            ]
        ] [
            arg: compose/only [a: (arg)]
        ]
    ] [
        arg: copy []
    ]

    ; see https://github.com/hostilefork/rebmu/issues/7
    ; We track the outermost Rebmu context via a variable in the user context.
    ; This allows us to effectively create a "new" user context holding all
    ; the Rebmu overrides.

    outermost: none? statics/context

    either outermost [
        context: copy rebmu-base-context
        append context arg

        ; Rebmu's own behavior replaces DO, no /NEXT support yet
        extend context 'do func [value] [
            either string? value [
                rebmu value
            ] [
                do value
            ]
        ]

        ; When we load, we want default binding to override with this context
        ; over system/contexts/user

        rebmu-load: func [source] compose [
            bind load source (context)
        ]

        extend context 'load :rebmu-load
        extend context 'ld :rebmu-load

        statics/context: context
    ] [
        context: statics/context
    ]
            
    bind code context
    bind injection context

    if env [
        return context
    ]

    set/any 'result try [
        do injection
        do code
    ]
    
    ; If we exit the last "Rebmu user" context, then reset it to none
    if outermost [
        statics/context: none
    ]

    if unset? :result [
        exit
    ]

    if error? :result [
        do :result
    ]

    :result
]

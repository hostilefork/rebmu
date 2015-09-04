Rebol [
    Title: "Rebmu Dialect"
    Purpose: {
        Rebol dialect designed for participating in "Code Golf"
        challenges
    }

    Author: {"Dr. Rebmu"}
    Home: https://github.com/hostilefork/rebmu
    License: 'bsd

    Date: 6-Apr-2014
    Version: 0.6.0

    ; Header conventions: http://www.rebol.org/one-click-submission-help.r
    File: %rebmu.reb
    Type: 'dialect
    Level: 'advanced

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
    ; WHAT REBOL DEFINES BY DEFAULT IN THE TWO-CHARACTER SPACE
    ;----------------------------------------------------------------------

    ; Very Reasonable Use of English Words

    ; TO    to conversion
    ; OR    or operator
    ; IN    word or block in the object's context
    ; IF    conditional if
    ; DO    evaluates a block, file, url, function word
    ; AT    returns the series at the specified index
    ; NO    logic false
    ; ON    logic true

    ; Reasonable use of Symbolic Operators

    ; ++    increment and return previous value
    ; --    decrement and return previous value
    ; ??    Debug print a word, path, block or such
    ; >=    true if the first value is greater than the second
    ; <>    true if the values are not equal
    ; <=    true if the first value is less than the second
    ; =?    true if the values are identical
    ; **    first number raised to the power of the second
    ; !=    true if the values are not equal

    ; The choice to take this prominent comment-to-end-of-line
    ; marker and make it mean the same thing as MOD seems unwise.
    ; There's nothing abstractly wrong with semicolon... it is one
    ; fewer character for a to-end-of-line comment.  But semicolons
    ; for comments is very "old-school" assembly and it gives the
    ; language a dated look just how capitalizing REBOL looks like
    ; COBOL.  I feel like if Rebol offered "//" as an alternative
    ; comment choice to ";" it would be more amicable, considering
    ; the rarity of modulus.  Rebol could be more popular if these
    ; issues were taken seriously!

    ; //    remainder of first value divided by second

    ; Maybe reasonable use of abbreviation in the default.  Could be
    ; carriage-return and line-feed and leave it to the user to
    ; abbreviate.

    ; CR    carraige return character
    ; LF    line feed character

    ; Questionable shorthands for terms defined elsewhere. Considering how
    ; many things do not have shorthands by default...what metric proved
    ; that *these four* were the ideal things to abbreviate?  They are
    ; only in Rebol 3.

    ; SP    alias for SPACE
    ; RM    alias for DELETE
    ; DP    alias for DELTA-PROFILE
    ; DT    alias for DELTA-TIME

    ; These are shell commands and it seems like there would be many more.
    ; Could there be a shell dialect, in which for instance issue values
    ; (#foo) could be environment variables, or something like that?  It
    ; seems many other things would be nice, like pushing directories or
    ; popping them, moving files from one place to another, etc.

    ; LS    print contents of a directory
    ; CD    change directory

    ; Another abbreviation that seems better to leave out
    ; DS    temporary stack debug

    ;----------------------------------------------------------------------
    ; DATATYPE SHORTHANDS (3 CHARS)
    ; Though I considered giving the datatypes 2-character names, I decided
    ; on 3 and saving the one-characters for things like INDEX? and OFFSET?
    ; and LENGTH?.   Literal words for types will probably not be showing
    ; up too often in Code Golf.
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
    IO: rebmu-wrap 'if/only [condition true-branch]
    IL: :if-lesser?-mu
    IG: :if-greater?-mu
    IE: :if-equal?-mu
    IU: :if-unequal?-mu
    IZ: :if-zero?-mu

    EI: :either
    EO: rebmu-wrap 'either/only [condition true-branch false-branch]
    EL: :either-lesser?-mu
    EG: :either-greater?-mu
    EE: :either-equal?-mu
    EU: :either-unequal?-mu  ; technically superflous, you can swap EE params
    EZ: :either-zero?-mu

    SW: :switch
    CA: :case
    CAA: rebmu-wrap 'case/all [block]

    UN: :unless
    UO: rebmu-wrap 'unless/only [condition false-branch]
    UZ: :unless-zero?-mu

    ;----------------------------------------------------------------------
    ; LOOPING CONSTRUCTS
    ;----------------------------------------------------------------------

    FR: :for
    FE: :foreach
    ME: :map-each
    RME: :remove-each-mu
    FA: :forall
    LP: :loop
    FV: :forever

    WH: :while
    WA: :rebmu-wrap 'while/after [cond-block body-block]
    WG: :while-greater?-mu
    WL: :while-lesser?-mu
    WGE: :while-greater-or-equal?-mu
    WLE: :while-lesser-or-equal?-mu
    WE: :while-equal?-mu
    WU: :while-unequal?-mu

    ; single-character U taken for UNLESS 
    UT: :until
    UTA: rebmu-wrap 'until/after [cond-block body-block]

    CN: :continue
    BR: :break
    TY: :try
    CC: :catch
    AM: :attempt

    ; There is debate on whether QUIT of a nested script should quit the
    ; caller or not.  This debate seems to have been resolved with the
    ; addition of CATCH/QUIT, which means that if you call a nested script
    ; that quits and you don't want it to *actually* quit...that's the
    ; caller's responsibility.  Also, the need for a "more quittier quit
    ; than quit" called QUIT/NOW is suspect.  Hence Rebmu is leading the
    ; way by making QT abbreviate what is known as QUIT/NOW and not
    ; offering a non-now-version of QUIT.  Hopefully Rebol3 and Red will
    ; follow suit and ditch NOW.

    QT: rebmu-wrap 'quit/now []

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
    DF: :does-function-mu
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
    ISP: rebmu-wrap 'insert/part [series value length]
    ISPO: rebmu-wrap 'insert/part/only [series value length]
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

    L?: :length?
    LN: :length? ;-- Reserved... LENGTH? => LENGTH is likely in Rebol3 final

    F?: :index?-find-mu
    O?: :offset?
    I?: :index?
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
    CT: :collect-mu
    LDA: rebmu-wrap 'load/all [source]
    CB: :combine
    CBW: rebmu-wrap 'combine/with [block delimiter]

    QO: :quote

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

    ; LG was originally used for type naming in logic, which isn't technically
    ; a conflict but a bit confusing; taking LC for that to avoid another
    ; non-conflict (but confusing) with LOOP.  Given Rebol's "human" bias it
    ; makes more sense to go with the base 10 default for logarithms, but lg10
    ; is available also.  lge fits the pattern and lines up better with the
    ; Rebol.  It might be tempting to abbreviate LN for natural log but it is
    ; looking like LENGTH? is going to become finalized as LENGTH in Rebol3
    ; because it does not yield a boolean result, while less common ? forms
    ; that do not return booleans will be suffixed with -OF so LN is reserved. 
    LG10: :log-10
    LG2: :log-2
    LGE: :log-e
    LG: :LG10

    ; ** is the infix power operator, but infix is sometimes not what you
    ; want so Rebol also has power as a prefix variant
    PW: :power

    ; I'm not entirely sure about the fate of tokens ending in a single
    ; tilde.  Rebol's default AND/OR/XOR are infix, and the prefix versions
    ; end in tildes.  That precedent guided my decision to create A~, O~,
    ; etc. but Rebol's infix OR is special and unlikely to be used in code
    ; golf... anyway, due to feedback that's now done with carets because
    ; of the desire to use tilde for the constructors.  An aesthetic choice.
    ; Will that feed back into the Rebol design?  Who knows...

    A^: :prefix-and-mu
    O^: :prefix-or-mu
    X^: :prefix-xor-mu
    N^: :not-mu

    ; Question: What other functions seem to fit in the theme of ending in
    ; carets?  These are just ideas
    F^: :only-first-true-mu
    S^: :only-second-true-mu

    EV?: :even?
    OD?: :odd?
    ++: :increment-mu
    --: :decrement-mu
    G^: :greater?           ; >~ is not a valid symbol in Rebol
    GE^: :greater-or-equal?     ; >=~ is not a valid symbol in Rebol
    L^: :lesser?            ; <~ is not a valid symbol in Rebol
    LE^: :lesser-or-equal?      ; <=~ is not a valid symbol in Rebol
    ==^: :strict-equal?
    NG?: :negative?
    SG?: :sign?
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

    RD: :read
    WR: :write
    PR: :print
    PRO: rebmu-wrap 'print/only [value]
    PB: :probe
    RI: :readin-mu
    RL: rebmu-wrap 'read/lines [source]
    NL: :newline

    ;----------------------------------------------------------------------
    ; STRINGS
    ;----------------------------------------------------------------------
    TR: :trim ; for true, use ON and for false use NO, test with Y? and N?
    TRT: rebmu-wrap 'trim/tail [series]
    TRH: rebmu-wrap 'trim/head [series]
    TRA: rebmu-wrap 'trim/all [series]
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
    RF: :redefine-mu
    EN: :encode
    SWP: :swap-exchange-mu
    FM: :format
    OS: :onesigned-mu
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
    ; SINGLE CHARACTER DEFINITIONS
    ;
    ; Originally Rebmu tried to define single characters as having values
    ; so you could have "a value of that type around" (x, y, z as 0.0 to
    ; have a float around, s to have an empty string, etc.)
    ;
    ; While helpful for golfing, it turned out to not be THAT helpful.
    ; And it taught nothing that would be relevant to Rebol or Red, as
    ; they would not be doing any such definitions by default.
    ;
    ; So the single character definitions were scaled back a bit.
    ;----------------------------------------------------------------------

    ; The dot operator is helpful for quickly redefining symbols used
    ; repeatedly .[aBCdEF] will unmush into .[a bc d ef] so you can
    ; always use it without the dot sticking to another symbol that isn't
    ; a digit

    .: :RF

    ; This set needs to have thought given to them.
    ; they breaks symbols; a^b becomes a^ b but A^b bcomes a: ^b
    ; ^foo is therefore good for construction functions which are going
    ; to target an assignment but little else.  getting a ^ in isolation
    ; requires situations like coming in front of a block or a string
    ; literal so it might make sense to define it as something that is
    ; frequently applied to series literals.  decoding base-64 strings
    ; might be an option as they are used a lot in code golf.
    ^: :caret-mu
    &: :DZ  ; "does" generator, can write context variables
    |: :DF  ; function generator w/no parameters, block always follows
    ~: none ; don't know yet
    ?: none

    ; TODO: there is an issue where if an argument a is put into the block
    ; you can't overwrite its context if you're inside something like a
    ; while block.  How to resolve this?

    ;a - usually a program argument or a-function variable
    ;b
    c: :CP
    ;d
    e: :EI ; "either"
    f: :FR ; "for"
    ;g
    ;h
    i: :IF
    ;j
    ;k
    l: :LP ; "loop"
    ;m
    ;n
    o: :OR ; "or"
    p: :PR ; this used to be "poke" and I'm not sure why; now "print"

    ; Q is tricky.  I've tried not to violate the meanings of any existing
    ; Rebol functions, but it seems like a waste to have an
    ; interpreter-only function like "quit" be taking up such a short
    ; symbol by default.

    q: :QO ; "quote"

    r: :RI ; "readin"
    ;s
    t: :TO ; note that to can use example types, e.g. t "foo" 10 is "10"!
    u: :UN ; "unless"
    ;v
    w: :WH ; "while"
    ;x
    ;y
    ;z
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
                print ["Original Rebmu string was:" length? code "characters."]
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
            length? mold/only code
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

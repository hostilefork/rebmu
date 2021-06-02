> **2013 VIDEO:** For a lighthearted introduction to Rebmu, see the [2013 Montreal Conference Video on YouTube](https://www.youtube.com/watch?v=iDKaz1iB9wQ).
>
> **2021 UPDATE:** Rebmu was written for an early version of the open-sourced R3-Alpha.  A reworking is pending to leverage the radically redesigned Ren-C (which runs in the browser via Wasm)...and will be undertaken when time permits.  In the meantime, please see [some talks from the Rebol 2019 Conference](https://2019.reb4.me/talks), the [Ren-C GitHub Repository](https://github.com/metaeducation/ren-c), and [forum.rebol.info](https://forum.rebol.info).

![Rebmu logo](https://raw.github.com/hostilefork/rebmu/master/rebmu-logo.png)

The Rebmu language is a dialect of Rebol which uses some unusual tricks to achieve smaller character counts in source code.  The goal is to make it easier to participate in programming challenges where the goal is to achieve a given task in as few characters as possible.

Despite being a little bit "silly"--as Code Golf is sort of silly--there is a serious side to the design.  Rebmu is a genuine dialect...meaning that it stands upon the Rebol and [Red](http://red-lang.org) common code-as-data format, which is coming to be referred to as [REN (REadable Notation)](https://github.com/humanistic/REN).  Thus Rebmu relegates most parsing--such as parentheses and block matches. This means that there's no string-oriented trickery taking advantage of illegal source token sequences in Rebol (like 1FOO, A$B...)

It is for this reason that Rebmu is quite small.  Rebol's [Apache-licensed cross-platform executable](http://rebolsource.net/) needed is a single binary file with no installation required...and there are only a few small scripts (seen here on GitHub) implementing Rebmu itself.  The half-megabyte interpreter includes quite an impressive set of functionality!

Leveraging the underlying logic of Rebol as well as somewhat natural naming, Rebmu programs can be very intuitive--despite the odd way they look at first.  Also, Rebmu is a superset of Rebol, so any Rebol code should be able to be used safely.  This is incredibly handy in debugging to temporarily switch in the midst of Rebmu to using non-shorthanded code!  When put under the microscope, you may agree that it is the most human-friendly "Pro golfer's" tool yet created!

While it could be argued that Rebmu is a "Rebol library" and not an independent "language", it purposefully demonstrates how Rebol blurs the distinction between these two.  Dialecting is a tool for bending the language as you see fit, as part of Rebol's "language construction set" philosophy.  One could make a reasonable case that it is no less a language than GolfScript is a set of routines running on its Ruby host.  Either way, hopefully it is at least interesting.  :-)


### NAMING ###

Despite several shorthands defined for common Rebol operations (even as far as `I` for `IF`) the functions are true to their Rebol bretheren across all inputs that Rebol accepts.  Current exceptions to this are q and ?, due to controversy on whether these rare abbreviations (Q for QUIT and ? for HELP) should be in the console only and not allowed in written Rebol scripts.  *(Due to their relative lack of literacy in Rebol's otherwise full-English aesthetic.)*  Instead Q was retaken for QUOTE.

P is a shortcut for PR, which is in turn a shortcut for PRINT.  This provides the ability to redefine P and use it as a variable if you are solving a problem that needs it while still having access to the abbreviated PR form if you must do so.

*(Note: At one time all single letters were given initial functions or values  This went as far as declaring B to be an empty block value, X Y Z as floating point values of 0.0, -1.0, and 1.0, etc.  Over the long run this somewhat contrived idea did not prove to make much of a dent in the ability for Rebmu to compete.  It was a small constant factor eclipsed by being able to choose any language.  So these were removed.)*

A big goal for the project is serving as a teaching tool for the Rebol and Red languages, while being fun and a highly serious competitive tool in code golf.  So the philosophy of naming in Rebmu tries to strike a balance between the necessary brevity and fidelity to the naming patterns of the language.  It is also biased away from necessarily giving commands oddly abbreviated names just for the sake of fitting them into fewer characters.

For instance: at one point RP was REPEND (a Rebolism) while RT was REPEAT with RN as RETURN.  Shifting this to RPN for REPEND and RP for REPEAT with RT as RETURN seeming more natural.  Ree-Peet lines up better with RP than the implied Repea-Tuh of RT, as does Ruh-Turn more suggest RT instead of Ruhtur-Nuh of RN.  This is a subjective issue and has been evolving as the dialect and philosophy stabilize.

A tough example of a naming choice was the decision to abbreviate CY for COPY and CP for COPY/PART.  While having a shorter name for the very useful COPY/PART is helpful for golfing, it doesn't necessarily teach Rebol as well as CP and CPP would: which reflects the additive nature of refinements and doesn't introduce a seemingly arbitrary difference in abbreviation.  In this case, the compromise was to default C to COPY and have CY be only a "fallback" you use if you overwrite C for your own variable use.  This makes the CP seem a less arbitrary abbreviation "out of the box".

Other examples like this are being contemplated and shifted as the design matures...so expect some churn.


### "MUSHING" ###

There is the obvious need to come up with abbreviations for long words like WH instead of WHILE.  Rebol is particularly good at allowing one to do this kind of thing within the language and without a preprocessor.  However, this takes it even farther using a technique fancifully named "mushing".

It doesn't really change the nature of the language--and is purely optional.  But it's funny, and it has an internal consistency to it.  You'll save 40% empirically, while being about as easy to read as pig-latin once you know the trick.

Mushed Rebol still passes the parser but uses particular sequences of upper and lower case terms and symbol processing within words:

    >> unmush [abcDEFghi]
    == [abc def ghi]

The choice to start a sequence of alternations with an uppercase run is used as a special indicator of wishing the first element in the sequence to be interpreted as a set-word:

    >> unmush [ABCdefGHI]
    == [abc: def ghi]

This applies to elements of paths as well.  Each path break presents an opportunity for a new alternation sequence, hence a set-word split:

    >> unmush [ABCdef/GHI]
    == [abc: def/ghi:]

    >> unmush [ABCdef/ghi]
    == [abc: def/ghi]

An exception to this rule are literal words, where since you cannot make a literal set-word in source the purpose is to allow you to indicate whether the *next* word should be a set-word.  Choosing lowercase for the lit word will mean the next word is a set-word, while uppercase means it will not be:

    >> unmush [abc'DEFghi]
    == [abc 'def ghi]

    >> unmush [abc'defGHI]
    == [abc 'def ghi:]

A get-word! cannot be made inline like this, because colons are used in URL types (even a:b is a url!).  But in the one case of leading colons, the same rule applies to the capitalization, indicating whether the second word will be a set-word or not:

    >> unmush [:abcDEFghi]
    == [:abc def: ghi]

    >> unmush [:ABCdefGHI]
    == [:abc def ghi]

A source-level set-word might seem to most sensibly make the last run a set-word.  But if you want [abc: def ghi:] then it is just as many characters to write [ABCdef GHI] as [ABCdefGHI:], so a cooler gimmick is needeed.  *(TBD: what cool trick should this enable?)*

Because symbols do not have a "case" they are handled specially.  Since Rebmu tries to be compatible with Rebol code (as long as it's all lowercase!) they generally act like lowercase letters, with a few caveats:

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

Digits are handled mostly the same as symbols, in that they will bind in a word as a single digit but stand alone in larger groups.  This makes initializations easy:

    [A10B20C00] => [a: 10 b: 20 c: 0]

There is a difference from symbol, when you switch from upper to lowercase across a single digit.  It would not make sense for it to bind to the head of the next symbol (invalid integer) so instead it sticks to the left:

    [A0b] => [a0: b]

Again, mushing is optional, and lowercase-code-with-spaces runs as normal.  So it's important to realize an implication of that.  *Unless there is an uppercase letter **somewhere** in a word or path sequence, nothing will unmush.*  That's why it doesn't apply in this case, for instance:

    [a00] => [a00]

The number of spaces and colons this can save on in Rebol code is significant, and it is easy to read and write once the rules are understood.  If you know Rebol, that is :)


### INVOCATION ###

Rebmu programs get their own execution context.  They will unmush their input, set up the environment of abbreviated routines, and run the code:

    >> rebmu [p"Hello World"]
    Hello World

**Passing Arguments**

Code golfing problems can be phrased as either *"define a function that does..."* or in terms of a very specific input/output script.  If you can get away with the former, you can also pass in named arguments via a block:

    >> rebmu/args [pSpM] [s: "Hello" m: "World"]
    Hello
    World

The argument block can even use Rebmu code and conventions:

    >> rebmu/args [pSpM] [S"Hello"M"World"]
    Hello
    World

Or you can pass in a block which does not begin with a SET-WORD! and that block will appear in the execution context as the variable A

    >> rebmu/args [pA] [1 2 3]
    1 2 3

**Injecting Code**

You can run your Rebmu program and let it set some values in its environment, such as defining functions you might want to call.  Using the /INJECT refinement you can run some code after the program has executed but before the environment is disposed.

For instance, the following example uses a shorthand format for defining a function that triples a number and saving it in t:

    >> rebmu [Ta|[a*3]]

But defining the function isn't enough to call it, so if you had wanted to do that you could have said:

    >> rebmu/inject [Ta|[a*3]] [pT10]
    30

The injected code is just shorthand for `[p t 10]`, printing the result of calling T with an argument value of 10.

**Statistics**

There's a helper for counting the characters:

    >> rebmu/stats {A10pApApA}
    Original Rebmu string was: 9 characters.
    Rebmu as mushed Rebol block molds to: 9 characters.
    Unmushed Rebmu molds to: 17 characters.
    10
    10
    10

Note that if you pass your code in as a block, you'll get a warning since the statistics may be incorrect.  The result of converting a REN data block to a string will not always give you the exact number of characters that were put in.

**Debugging**

It can help to find errors by using the feature that shows you the unmushed version of the code before it's executed:

    >> rebmu/debug {A10pApApA}
    Executing: [a: 10 p a p a p a]
    10
    10
    10


### DISCUSSION ###

A prerequisite to using Rebmu is to know some Rebol (or Red).  If you're looking for help on golfing with Rebmu, please bring it up on [forum.rebol.info](https://forum.rebol.info).

The main place where the Code Golf problems are studied are on the [Code Golf StackExchange](http://codegolf.stackexchange.com/).  As a general rule, if you are going to post a Rebmu solution that is not substantially different from your Rebol answer (or an existing one) then just put it in the same answer...and present both counts in the header.  *(For instance **Rebmu: 20 chars, Rebol: 80 chars**)*  If it's someone else's Rebol answer, then add the Rebmu form as a comment or suggested edit.

Feel free to bring up any ideas also, on the [Rebmu GitHub issue tracker](https://github.com/hostilefork/rebmu/issues).

Best,
--"Dr. Rebmu" :-)

; http://codegolf.stackexchange.com/questions/2/99-bottles-of-beer

; b is a parameterless "func" that returns a string 
; "N bottle(s) of beer on the wall" with correct
; pluralization.
Bdz[rj[n{ bottle}egN 1{s}{}{ of beer}]]

; start both m and n at 99
M99Nm

; loop n times (99)
loN[

  ; "print rejoin"
  ; rejoin is an operation which REduces ("evals")
  ; expressions in a block, and then JOINs them into
  ; a string.  So rejoin [{Hello } 1 + 2 { world.}]
  ; gives back the string {Hello 3 world.}
  prRJ[
  
    ; invoke b, returns the N bottles of beer string
    b
    
    ; sets w to the string " on the wall" and also
    ; evaluates to " on the wall"
    W{ on the wall}
    
    ; same set/return except now it's c for comma-space
    C{, }
    
    ; invoke b again
    b
    
    ; same set/return except now it's p for period-linefeed
    ; ("^/" is Rebol's "\n", basically carets 
    ; are considered to be less common in strings than
    ; carets due to things like directory paths, so they
    ; were chosen for escape.)
    P{.^/}

    ; shorthand for either -- n > 1 (eg=either-greater)
    ; the either statement is like an "if-else", and
    ; takes two blocks.  It evaluates the first if
    ; the condition is true and the second if it's 
    ; false.  The end result of evaluating a block is
    ; the last value in that block (like in Ruby)
    eg--N 1{Take one down and pass it around}[
      
      ; reset n to 99...
      Nm

      ; ...but evaluate this else clause to a string
      {Go to the store and buy some more}
    ]

    ; invoking the comma-period value we stored (c)
    ; call b, with new # of bottles of beer in effect
    ; using the " on the wall" string we stored (w)
    ; finally the period-linefeed (p)
    cBwP
  ]
]

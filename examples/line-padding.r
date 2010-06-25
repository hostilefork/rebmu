; From AltME chat:
; *** Modify a text, so that all lines have the same length  (by adding trailing spaces)
;
; ** input: 
; - a multi-lines string
; - the expected length of lines (minus LF)
; ** Goal:
; - The shortest function win (not the fastest).

; Invoke using named inputs, e.g.
; rebmu/args %examples/line-padding.r [t: {^/1^/22^/333^/4444^/55555^/666666} c: #"#" l: 4]

; could bracket in us's[ ... ] for a use block that protected s

comment [
; >> unmush [wh[SfiTlf][loADlO?sT[SisSc]TntS]hdT]
; == [wh [s: fi t lf] [lo ad l o? s t [s: is s c] t: nt s] hd t]

	while [s: find t lf] [
		loop add l offset? s t [
			s: insert s c
		]
		t: next s
		head t
	]
]

; 35 chars
wh[SfiTlf][loADlO?sT[SisSc]TntS]hdT
Rebol [
    Title: "Rebmu Roman Numeral Converter Test"
]

num-failures: 0

for-each [roman _ decimal] [
    "I" => 1
    "IX" => 9
    "MCXI" => 1111
    "MMCCXXII" => 2222
    "MMMCCCXXXIII" => 3333
    "MMMDCCCLXXXVIII" => 3888
    "MMMCMXCIX" => 3999
][
    result: copy {}

    apply :call [
        [(system.options.boot) --do
            "import %rebmu.reb, rebmu/output %examples/roman.rebmu"
        ]
        /input join roman newline
        /output result
    ]

    result: trim/tail result  ; output has a newline on it

    if (mold decimal) = result [
        print ["SUCCESS:" roman "=>" decimal]
    ] else [
        num-failures: me + 1
        print ["FAILURE:" roman "=>" result "(Expected:" decimal ")"]
    ]
]

if num-failures <> 0 [
    fail ["!!!" num-failures "TESTS FAILED !!!"]
]

Red [
    Title: "Crimson"
    Author: "RaycatWhoDat"
    File: %crimson.red
    Tabs: 4
    Version: 0.0.10
    Description: {
        Crimson is a collection of functions and operators
        I found myself wanting as I made test projects with Red.
    }
]

crimson: context [
    keep-occurrences: function [
        "Base function for keep-occurrences behavior."
        iterable [block! string!] "The iterable to parse over."
        item [block! typeset! datatype! string!] "The item to find in the iterable."
        return: [block!]
    ] [
        if all [
            string? iterable
            not string? item
        ] [
            do make error! "KEEP-OCCURRENCES can only accept any-string! when parsing over any-string!"
        ]
        parse iterable [collect [some [to item keep item]]]
    ]
    
    only: make op! function [
        "Returns all occurrences of ITEM in ITERABLE."
        iterable [block! string!] "The iterable to parse over."
        item [block! typeset! datatype! string!] "The item to find in the iterable."
        return: [block!]
    ] [
        keep-occurrences iterable item
    ]
    
    assert: function [
        "Throws an exception if a condition is false."
        :test-condition [any-type!] "The conditional in question."
        message [block! string!] "The message to display when throwing the exception."
    ] [
        unless do :test-condition [
            both-sides: test-condition only any-type!
            print compose ["Expected:" both-sides]
            print compose ["Actual:" (first both-sides)]
            do make error! either block? message [rejoin message] [message]
        ]
    ]
        
    flatten: function [
        "Returns a flattened block of items."
        series [block!] "The block of items to flatten."
        return: [block!]
        /deep "Flattens each nested block when present."
    ] [
        either deep [
            flattened-series: make block! length? series
            nested-block: [
                into [some nested-block]
                | set value skip (append flattened-series value)
            ]
            parse series [some nested-block]
            flattened-series
        ] [
            flattened-series: make block! length? series
            head any [
                foreach value series [
                    insert tail flattened-series value
                ]
                flattened-series
            ]
        ]
    ]
    
    zip: function [
        "Base function for zipping behavior."
        first-block [block!] "The first block to zip."
        second-block [block!] "The second block to zip."
        /flat "Flattens items when present."
        return: [block!]
    ] [
        items: collect [
            forall first-block [
                keep/only append to block! first-block/1 pick second-block index? first-block
            ]
        ]
        either flat [flatten items] [items]
    ]
    
    Z: make op! function [
        "Returns a series of blocks with items corresponding with both iterables."
        first-block [block!] "The first block to zip."
        second-block [block!] "The second block to zip."
        return: [block!]
    ] [
        zip first-block second-block
    ]
    
    Z!: make op! function [
        "Returns a flattened block with items corresponding with both iterables. NOTE: This will not compose nicely if you don't use it as the last zipping operation."
        first-block [block!] "The first block to zip."
        second-block [block!] "The second block to zip."
        return: [block!]
    ] [
        zip/flat first-block second-block
    ]

    ..: make op! function [
        "Returns all natural numbers between and including START and END."
        start [integer! float!] "The first number in the range."
        end [integer! float!] "The last number in the range."
        return: [block!]
    ] [
        if start = end [return []]
        is-start-smaller: start < end
        total: either is-start-smaller [end - start + 1] [start - end + 1]
        collect [
            repeat index total [
                keep start + either is-start-smaller [index - 1] [-1 * (index - 1)]
            ]
        ]
    ]
    
    R: function [
        "Returns all natural numbers between and including 1 and including END."
        end [number!] "The last number in the range."
        return: [block!]
    ] [
        either end > 1 [
            1 .. end
        ] [
            []
        ]
    ]
    
    chunk: function [
        "Returns a block of blocks, in groups of SIZE."
        iterable [block! string!] "The iterable to parse over."
        size [integer!] "The size of each block."
        return: [block!]
    ] [
        assert [size > 0] "SIZE cannot be less than 1."
        collect [
            items: []
            forall iterable [
                append items iterable/1
                is-last-item: (length? iterable) = 1
                is-items-full: (length? items) >= size
                if any [is-last-item is-items-full] [
                    keep/only copy items clear items
                ]
                if is-last-item [break]
            ]
        ]
    ]
    
    max-of-series: function [
        "Returns the largest in a series, assuming the first item's datatype! is the same as the rest of the items."
        series [block!] "The series to check."
        return: [block!]
    ] [
        type-assumption: type? series/1
        all-comparable-items: series only type-assumption
        largest-item: none
        foreach item all-comparable-items [
            if any [none? largest-item item > largest-item] [
                largest-item: item
            ]
        ]
        largest-item
    ]

    weave: function [
        "Given a BLOCK! and ANY-TYPE!, returns a BLOCK! with ANY-TYPE! in-between each word."
        series [block!] "The series to weave."
        item [any-type!] "The item to insert."
        return: [block!]
    ] [
        collect [forall series [keep series/1 keep/only item]]
    ]

    explode: function [
        "Given ANY-STRING!, returns a BLOCK! of CHAR!."
        item [string!] "The string to explode."
        return: [block! [char!]] 
    ] [
        extract/into item 1 copy []
    ]

    char-to-integer: function [
        "Given a CHAR!, this will return a INTEGER! of the value, not the code point."
        character [char!] "The character to convert."
        return: [integer!]
    ] [
        to-integer to-string character
    ]

    format: function [
        "Given a string with special identifiers, replace the string with the items provided in the block."
        format-string [string!]
        items [block!]
        return: [string!]
    ] [
        digits: charset [#"1" - #"9"]
        slot-marker: ["{" digits "}"]
        slot-marker-rule: [
            to slot-marker
            slot-point:
            (slot-index: char-to-integer slot-point/2)
            (replace slot-point slot-marker items/:slot-index)
        ]
        
        if empty? items [
            print "No values provided."
            exit
        ]
        
        if (length? items) > 9 [
            print "No more than 9 arguments are supported at this time."
            exit
        ]

        parse format-string [some slot-marker-rule]
        format-string
    ]

    sequence: function [
        "Given a block of initial values and a step function, return a block of values generated from step-function."
        initial-values [block!] "The block of initial values."
        step-function [function!] "The function to generate the next value."
        /take iterations [integer!] "The number of times step-function should be invoked."
        /capped logic-block [block!] "A block that is valid in the ALL function. Use `value` to indicate the value generated from step-function."
        return: [block!]
    ] [
        if empty? initial-values [
            return []
        ]
        
        function-spec: spec-of :step-function
        remove-each spec-word function-spec [not word? spec-word]
        step-function-arity: length? function-spec
        
        if none? items [
            items: copy initial-values
        ]
        
        append-next-value: does [
            next-value: reduce reverse collect [
                repeat count step-function-arity [
                    keep (pick reverse copy items count)
                ]
                keep :step-function
            ]
            append items next-value
        ]
        
        capped-append: does [
            until [
                append-next-value
                conditional: copy logic-block
                replace/all conditional 'value (last items)
                do all conditional
            ]
        ]
        
        limited-append: does [
            repeat count iterations [append-next-value]
        ]
        
        case [
            capped [capped-append]
            take [limited-append]
            true [append-next-value]
        ]
        
        items
    ]
    
    internal: context [
        is-crimson-installed: false
        excluded-words: [internal keep-occurrences zip]

        install: does [
            foreach word words-of crimson [
                unless none? find internal/excluded-words word [continue]
                set (in system/words word) (select crimson word)
            ]
            is-crimson-installed: true
            print "Crimson is installed."
        ]
        
        generate-reference: does [
            help-file-path: %reference.md

            delete help-file-path
            ; Workaround until you can properly parse a Red header
            library-header: pick load %crimson.red 2
            write/append help-file-path rejoin ["# Crimson v" library-header/version newline newline]
            write/append help-file-path rejoin ["## API Reference" newline]
            foreach word words-of crimson [
                unless none? find excluded-words word [continue]
                write/append help-file-path rejoin ["### " word newline "```" newline]
                write/append help-file-path rejoin [help-string (to word! word) "```" newline]
            ]
            print rejoin ["Regenerated " help-file-path "."]
        ]

        run-tests: does [
            unless is-crimson-installed [
                do make! error "Running Crimson's tests requires Crimson to be ^"installed^" into the global context."
            ]

            ; Keep-occurrences tests
            ; ======================
            assert [((R 10) only number!) = [1 2 3 4 5 6 7 8 9 10]] [
                "Keep-occurrences did not return the correct result."
            ]
            
            assert [([none 1 "a" 2 "b" 3 "c"] only number!) = [1 2 3]] [
                "Keep-occurrences did not return the correct result."
            ]
            
            assert [([none 1 "a" 2 "b" 3 "c"] only string!) = ["a" "b" "c"]] [
                "Keep-occurrences did not return the correct result."
            ]
            
            assert [("this is a test" only "t") = [#"t" #"t" #"t"]] [
                "Keep-occurrences did not return the correct result."
            ]
                  
            ; Flatten tests
            ; =============
            assert [(flatten (R 5) Z (6 .. 10)) = [1 6 2 7 3 8 4 9 5 10]] [
                "Flatten did not return the correct result."
            ]
            
            assert [(flatten/deep [-1 0 [1 2 [3 4 5 [6]]]]) = [-1 0 1 2 3 4 5 6]] [
                "Flatten/deep did not return the correct result."
            ]
            
            
            ; Zip tests
            ; =========
            assert [(R 5) Z (6 .. 10) = [[1 6] [2 7] [3 8] [4 9] [5 10]]] [
                "Zip (Z) did not return correct the result."
            ]
            
            assert [(R 5) Z (6 .. 10) Z (11 .. 15) = [[1 6 11] [2 7 12] [3 8 13] [4 9 14] [5 10 15]]] [
                "Zip (Z) does not compose properly."
            ]
            
            assert [(R 5) Z! (6 .. 10) = [1 6 2 7 3 8 4 9 5 10]] [
                "Flattening zip (Z!) did not return correct the result."
            ]
            

            ; Range tests
            ; ===========
            assert [(1 .. 10) = [1 2 3 4 5 6 7 8 9 10]] [
                "Small Pos to Large Pos did not return the correct result."
            ]
            
            assert [(10 .. 1) = [10 9 8 7 6 5 4 3 2 1]] [
                "Large Pos to Small Pos did not return the correct result."
            ]
            
            assert [(-10 .. -1) = [-10 -9 -8 -7 -6 -5 -4 -3 -2 -1]] [
                "Small Neg to Large Neg did not return the correct result."
            ]
            
            assert [(-1 .. -10) = [-1 -2 -3 -4 -5 -6 -7 -8 -9 -10]] [
                "Large Neg to Small Neg did not return the correct result."
            ]
            
            assert [(-5 .. 5) = [-5 -4 -3 -2 -1 0 1 2 3 4 5]] [
                "Small Neg to Large Pos did not return the correct result."
            ]
            
            assert [(5 .. -5) = [5 4 3 2 1 0 -1 -2 -3 -4 -5]] [
                "Large Pos to Small Neg did not return the correct result."
            ]
            
            assert [(R 10) = [1 2 3 4 5 6 7 8 9 10]] [
                "Unspecified Large Pos did not return the correct result."
            ]
            
            assert [(0 .. 0) = []] [
                "Same Ends did not return the correct result."
            ]
            
            
            ; Chunk tests
            ; ===========
            assert [(chunk (R 10) 2) = [[1 2] [3 4] [5 6] [7 8] [9 10]]] [
                "Chunk did not return the correct result."
            ]
            
            assert [(chunk (R 9) 2) = [[1 2] [3 4] [5 6] [7 8] [9]]] [
                "Chunk did not return the correct result."
            ]
            
            
            ; Max-of-series tests
            ; ===================
            assert [(max-of-series (-10 .. -1)) = -1] [
                "Max-of-series did not return the correct result."
            ]
            
            assert [(max-of-series (-10 .. 10)) = 10] [
                "Max-of-series did not return the correct result."
            ]
            
            assert [(max-of-series [-32 "e" 1 "a" 42]) = 42] [
                "Max-of-series did not return the correct result."
            ]
            

            ; Weave tests
            ; ===========
            assert [(weave R 3 1) = [1 1 2 1 3 1]] [
                "Weave did not return the correct result."
            ]
            
            assert [(weave R 3 "test") = [1 "test" 2 "test" 3 "test"]] [
                "Weave did not return the correct result."
            ]
            
            assert [(weave R 3 R 3) = [1 [1 2 3] 2 [1 2 3] 3 [1 2 3]]] [
                "Weave did not return the correct result."
            ]
            

            ; Format tests
            ; ============
            assert [(format "This {1}" ["is a test"]) = "This is a test"] [
                "Format did not return the correct result."
            ]
            
            assert [(format "This is {1} and {1}" ["anotha one"]) = "This is anotha one and anotha one"] [
                "Format did not return the correct result."
            ]
            
            assert [(format "This {1} {2} {3}" ["is" "a" "test"]) = "This is a test"] [
                "Format did not return the correct result."
            ]

            ; Sequence tests
            ; ==============
            fibonacci: function [item1 item2] [item1 + item2]
            assert [(sequence/capped [0 1] :fibonacci [value > 89]) = [0 1 1 2 3 5 8 13 21 34 55 89 144]] [
                "Capped sequence did not return the correct result."
            ]
            
            assert [(sequence/take [0 1] :fibonacci 7) = [0 1 1 2 3 5 8 13 21]] [
                "Limited sequence did not return the correct result."
            ]
            
            assert [(sequence [0 1] :fibonacci) = [0 1 1]] [
                "Uncapped sequence did not return the correct result."
            ]
        ]
    ]
]

; Bind all words to the global context
; crimson/internal/install

; Generate reference documentation
; crimson/internal/generate-reference

; Run all tests
; crimson/internal/run-tests
module Morphir.Value.InterpreterTests exposing (..)

import Dict
import Expect
import Morphir.IR.FQName exposing (fqn)
import Morphir.IR.Literal exposing (Literal(..))
import Morphir.IR.SDK as SDK
import Morphir.IR.Value as Value
import Morphir.Value.Error exposing (Error(..))
import Morphir.Value.Interpreter exposing (Reference(..), evaluate)
import Test exposing (Test, describe, test)


evaluateValueTests : Test
evaluateValueTests =
    let
        refs =
            SDK.nativeFunctions
                |> Dict.map
                    (\_ fun ->
                        NativeReference fun
                    )

        positiveCheck desc input expectedOutput =
            test desc
                (\_ ->
                    evaluate refs input
                        |> Expect.equal
                            (Ok expectedOutput)
                )

        negativeCheck desc input errorMessage =
            test desc
                (\_ ->
                    evaluate refs input
                        |> Expect.equal
                            (Err errorMessage)
                )
    in
    describe "evaluateValue"
        [ positiveCheck "True = True"
            (Value.Literal () (BoolLiteral True))
            (Value.Literal () (BoolLiteral True))
        , positiveCheck "not True == False"
            (Value.Apply ()
                (Value.Reference () (fqn "Morphir.SDK" "Basics" "not"))
                (Value.Literal () (BoolLiteral True))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck "True && False == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "and"))
                    (Value.Literal () (BoolLiteral True))
                )
                (Value.Literal () (BoolLiteral False))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck "False && True == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "and"))
                    (Value.Literal () (BoolLiteral False))
                )
                (Value.Literal () (BoolLiteral True))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck "2 + 4 == 6"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "add"))
                    (Value.Literal () (IntLiteral 2))
                )
                (Value.Literal () (IntLiteral 4))
            )
            (Value.Literal () (IntLiteral 6))
        , positiveCheck "6.2 + 4.8 == 11"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "add"))
                    (Value.Literal () (FloatLiteral 6.2))
                )
                (Value.Literal () (FloatLiteral 4.8))
            )
            (Value.Literal () (FloatLiteral 11))
        , positiveCheck "1000000000000 + 2000000000000 == 3000000000000"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "add"))
                    (Value.Literal () (IntLiteral 1000000000000))
                )
                (Value.Literal () (IntLiteral 2000000000000))
            )
            (Value.Literal () (IntLiteral 3000000000000))

        --, positiveCheck "2 + 4.2 == 6.2"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "add"))
        --            (Value.Literal () (IntLiteral 2))
        --        )
        --        (Value.Literal () (FloatLiteral 4.2))
        --    )
        --    (Value.Literal () (FloatLiteral 6.2))
        --, positiveCheck "10.5 + 3 == 13.5"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "add"))
        --            (Value.Literal () (FloatLiteral 10.5))
        --        )
        --        (Value.Literal () (IntLiteral 3))
        --    )
        --    (Value.Literal () (FloatLiteral 13.5))
        , positiveCheck "1000000000000 - 1000000000000 == 0"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "subtract"))
                    (Value.Literal () (IntLiteral 1000000000000))
                )
                (Value.Literal () (IntLiteral 1000000000000))
            )
            (Value.Literal () (IntLiteral 0))
        , positiveCheck " 100 - 0.4 == 99.6"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "subtract"))
                    (Value.Literal () (FloatLiteral 100))
                )
                (Value.Literal () (FloatLiteral 0.4))
            )
            (Value.Literal () (FloatLiteral 99.6))

        --, positiveCheck " 17 - 0.8 == 16.2"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "subtract"))
        --            (Value.Literal () (IntLiteral 17))
        --        )
        --        (Value.Literal () (FloatLiteral 0.8))
        --    )
        --    (Value.Literal () (FloatLiteral 16.2))
        --, positiveCheck " 30.6 - 2 == 28.6"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "subtract"))
        --            (Value.Literal () (FloatLiteral 30.6))
        --        )
        --        (Value.Literal () (IntLiteral 2))
        --    )
        --    (Value.Literal () (FloatLiteral 28.6))
        , positiveCheck " 0.4 mul 5.0 == 2.0"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "multiply"))
                    (Value.Literal () (FloatLiteral 0.4))
                )
                (Value.Literal () (FloatLiteral 5))
            )
            (Value.Literal () (FloatLiteral 2))
        , positiveCheck " 3 mul 5 == 15"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "multiply"))
                    (Value.Literal () (IntLiteral 3))
                )
                (Value.Literal () (IntLiteral 5))
            )
            (Value.Literal () (IntLiteral 15))

        --, positiveCheck " 10 mul 5.0 == 50.0"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "multiply"))
        --            (Value.Literal () (IntLiteral 10))
        --        )
        --        (Value.Literal () (FloatLiteral 5))
        --    )
        --    (Value.Literal () (FloatLiteral 50))
        --, positiveCheck " 30.2 mul 5 == 151.0"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "multiply"))
        --            (Value.Literal () (FloatLiteral 30.2))
        --        )
        --        (Value.Literal () (IntLiteral 5))
        --    )
        --    (Value.Literal () (FloatLiteral 151))
        , positiveCheck "4.0 / 2.0 == 2.0"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "divide"))
                    (Value.Literal () (FloatLiteral 4))
                )
                (Value.Literal () (FloatLiteral 2))
            )
            (Value.Literal () (FloatLiteral 2))
        , positiveCheck "2.0 / 5.0 == 0.4"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "divide"))
                    (Value.Literal () (FloatLiteral 2))
                )
                (Value.Literal () (FloatLiteral 5))
            )
            (Value.Literal () (FloatLiteral 0.4))
        , positiveCheck "7.5 / 0.0 == Infinite"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "divide"))
                    (Value.Literal () (FloatLiteral 7.5))
                )
                (Value.Literal () (FloatLiteral 0))
            )
            (Value.Literal () (FloatLiteral (1 / 0)))
        , positiveCheck "1.0 / 10.0 == 0.1"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "divide"))
                    (Value.Literal () (FloatLiteral 1.0))
                )
                (Value.Literal () (FloatLiteral 10.0))
            )
            (Value.Literal () (FloatLiteral 0.1))
        , positiveCheck " 100 < 100 == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (IntLiteral 100))
                )
                (Value.Literal () (IntLiteral 100))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck " -10.0 < -100.0 == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (FloatLiteral -10))
                )
                (Value.Literal () (FloatLiteral -100))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck " 10 < -100 == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (IntLiteral 10))
                )
                (Value.Literal () (IntLiteral -100))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck " 10.6 < -10.2 == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (FloatLiteral 10.6))
                )
                (Value.Literal () (FloatLiteral -10.2))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck " 10.111 < 10.112  == True"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (FloatLiteral 10.111))
                )
                (Value.Literal () (FloatLiteral 10.112))
            )
            (Value.Literal () (BoolLiteral True))

        --, positiveCheck " 5 < 2.5 == False"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
        --            (Value.Literal () (IntLiteral 5))
        --        )
        --        (Value.Literal () (FloatLiteral 2.5))
        --    )
        --    (Value.Literal () (BoolLiteral False))
        --, positiveCheck " 10.111 < 12  == True"
        --    (Value.Apply ()
        --        (Value.Apply ()
        --            (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
        --            (Value.Literal () (FloatLiteral 10.111))
        --        )
        --        (Value.Literal () (IntLiteral 12))
        --    )
        --    (Value.Literal () (BoolLiteral True))
        , positiveCheck " 'a' < 'c'  == True"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (CharLiteral 'a'))
                )
                (Value.Literal () (CharLiteral 'c'))
            )
            (Value.Literal () (BoolLiteral True))
        , positiveCheck " 'a' < 'a'  == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (CharLiteral 'a'))
                )
                (Value.Literal () (CharLiteral 'a'))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck " 'z' < 'a'  == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (CharLiteral 'z'))
                )
                (Value.Literal () (CharLiteral 'a'))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck " \"ball\" < \"bool\"  == True"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (StringLiteral "ball"))
                )
                (Value.Literal () (StringLiteral "bool"))
            )
            (Value.Literal () (BoolLiteral True))
        , positiveCheck " \"ball\" < \"ball\"  == False"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                    (Value.Literal () (StringLiteral "ball"))
                )
                (Value.Literal () (StringLiteral "ball"))
            )
            (Value.Literal () (BoolLiteral False))
        , positiveCheck " sum [1,3]  == 4"
            (Value.Apply ()
                (Value.Reference () (fqn "Morphir.SDK" "List" "sum"))
                (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 3) ])
            )
            (Value.Literal () (IntLiteral 4))
        , positiveCheck " sum [1,-1]  == 0"
            (Value.Apply ()
                (Value.Reference () (fqn "Morphir.SDK" "List" "sum"))
                (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral -1) ])
            )
            (Value.Literal () (IntLiteral 0))
        , positiveCheck " append [1,2,3] [1,2] == [1,2,3,1,2]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2), Value.Literal () (IntLiteral 3) ])
                )
                (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2) ])
            )
            (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2), Value.Literal () (IntLiteral 3), Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2) ])
        , positiveCheck " append [1,2,3] [] == [1,2,3]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2), Value.Literal () (IntLiteral 3) ])
                )
                (Value.List () [])
            )
            (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2), Value.Literal () (IntLiteral 3) ])
        , positiveCheck " append [] [1,2] == [1,2]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List () [])
                )
                (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2) ])
            )
            (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2) ])
        , positiveCheck " append [] [] == []"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List () [])
                )
                (Value.List () [])
            )
            (Value.List () [])
        , positiveCheck " append [True, False] [False,True] == [True, False,False,True]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List () [ Value.Literal () (BoolLiteral True), Value.Literal () (BoolLiteral False) ])
                )
                (Value.List () [ Value.Literal () (BoolLiteral False), Value.Literal () (BoolLiteral True) ])
            )
            (Value.List () [ Value.Literal () (BoolLiteral True), Value.Literal () (BoolLiteral False), Value.Literal () (BoolLiteral False), Value.Literal () (BoolLiteral True) ])
        , positiveCheck " append ['a','b'] ['c'] == ['a','b','c']"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List () [ Value.Literal () (CharLiteral 'a'), Value.Literal () (CharLiteral 'b') ])
                )
                (Value.List () [ Value.Literal () (CharLiteral 'c') ])
            )
            (Value.List () [ Value.Literal () (CharLiteral 'a'), Value.Literal () (CharLiteral 'b'), Value.Literal () (CharLiteral 'c') ])
        , positiveCheck " append [\"Hello\",\"World\"] [\"Happy\", \"?\"] == [\"Hello\",\"World\",\"Happy\", \"?\"]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List () [ Value.Literal () (StringLiteral "Hello"), Value.Literal () (StringLiteral "World") ])
                )
                (Value.List () [ Value.Literal () (StringLiteral "Happy"), Value.Literal () (StringLiteral "?") ])
            )
            (Value.List () [ Value.Literal () (StringLiteral "Hello"), Value.Literal () (StringLiteral "World"), Value.Literal () (StringLiteral "Happy"), Value.Literal () (StringLiteral "?") ])
        , positiveCheck " append [9,0,8,10] [1,5,3,9,6] == [9,0,8,10,1,5,3,9,6]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "append"))
                    (Value.List ()
                        [ Value.Literal () (IntLiteral 9)
                        , Value.Literal () (IntLiteral 0)
                        , Value.Literal () (IntLiteral 8)
                        , Value.Literal () (IntLiteral 10)
                        ]
                    )
                )
                (Value.List ()
                    [ Value.Literal () (IntLiteral 1)
                    , Value.Literal () (IntLiteral 5)
                    , Value.Literal () (IntLiteral 3)
                    , Value.Literal () (IntLiteral 9)
                    , Value.Literal () (IntLiteral 6)
                    ]
                )
            )
            (Value.List () [ Value.Literal () (IntLiteral 9), Value.Literal () (IntLiteral 0), Value.Literal () (IntLiteral 8), Value.Literal () (IntLiteral 10), Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 5), Value.Literal () (IntLiteral 3), Value.Literal () (IntLiteral 9), Value.Literal () (IntLiteral 6) ])
        , positiveCheck " concat [\"a\",\"b\",\"123\"] == \"ab123\""
            (Value.Apply ()
                (Value.Reference () (fqn "Morphir.SDK" "String" "concat"))
                (Value.List () [ Value.Literal () (StringLiteral "a"), Value.Literal () (StringLiteral "b"), Value.Literal () (StringLiteral "123") ])
            )
            (Value.Literal () (StringLiteral "ab123"))
        , positiveCheck " concat [] == \"\""
            (Value.Apply ()
                (Value.Reference () (fqn "Morphir.SDK" "String" "concat"))
                (Value.List () [])
            )
            (Value.Literal () (StringLiteral ""))
        , positiveCheck "if 100 < 1000 then 2 else 3"
            (Value.IfThenElse ()
                (Value.Apply ()
                    (Value.Apply ()
                        (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                        (Value.Literal () (IntLiteral 100))
                    )
                    (Value.Literal () (IntLiteral 1000))
                )
                (Value.Literal () (IntLiteral 2))
                (Value.Literal () (IntLiteral 3))
            )
            (Value.Literal () (IntLiteral 2))
        , positiveCheck "if 1000 < 100 then 2 else 3"
            (Value.IfThenElse ()
                (Value.Apply ()
                    (Value.Apply ()
                        (Value.Reference () (fqn "Morphir.SDK" "Basics" "lessThan"))
                        (Value.Literal () (IntLiteral 1000))
                    )
                    (Value.Literal () (IntLiteral 100))
                )
                (Value.Literal () (IntLiteral 2))
                (Value.Literal () (IntLiteral 3))
            )
            (Value.Literal () (IntLiteral 3))
        , positiveCheck "map (\\a -> a//2)  [2,4,6] = [1,2,3]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "map"))
                    (Value.Lambda ()
                        (Value.AsPattern () (Value.WildcardPattern ()) [ "a" ])
                        (Value.Apply ()
                            (Value.Apply ()
                                (Value.Reference () (fqn "Morphir.SDK" "Basics" "integerDivide"))
                                (Value.Variable () [ "a" ])
                            )
                            (Value.Literal () (IntLiteral 2))
                        )
                    )
                )
                (Value.List () [ Value.Literal () (IntLiteral 2), Value.Literal () (IntLiteral 4), Value.Literal () (IntLiteral 6) ])
            )
            (Value.List () [ Value.Literal () (IntLiteral 1), Value.Literal () (IntLiteral 2), Value.Literal () (IntLiteral 3) ])
        , positiveCheck
            "map not [True,False,True] = [False,True,False]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "map"))
                    (Value.Reference () (fqn "Morphir.SDK" "Basics" "not"))
                )
                (Value.List () [ Value.Literal () (BoolLiteral True), Value.Literal () (BoolLiteral False), Value.Literal () (BoolLiteral True) ])
            )
            (Value.List () [ Value.Literal () (BoolLiteral False), Value.Literal () (BoolLiteral True), Value.Literal () (BoolLiteral False) ])
        , positiveCheck "map (\\a -> -a)  [2,4,6] = [-2,-4,-6]"
            (Value.Apply ()
                (Value.Apply ()
                    (Value.Reference () (fqn "Morphir.SDK" "List" "map"))
                    (Value.Lambda ()
                        (Value.AsPattern () (Value.WildcardPattern ()) [ "a" ])
                        (Value.Apply ()
                            (Value.Apply ()
                                (Value.Reference () (fqn "Morphir.SDK" "Basics" "subtract"))
                                (Value.Literal () (IntLiteral 0))
                            )
                            (Value.Variable () [ "a" ])
                        )
                    )
                )
                (Value.List () [ Value.Literal () (IntLiteral 2), Value.Literal () (IntLiteral 4), Value.Literal () (IntLiteral 6) ])
            )
            (Value.List () [ Value.Literal () (IntLiteral -2), Value.Literal () (IntLiteral -4), Value.Literal () (IntLiteral -6) ])
        ]

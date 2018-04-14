module Framework.Cards exposing (..)

import Color
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Framework.Color exposing (Color(..), color)
import Html
import Html.Attributes
import Regex


type alias Model =
    { flip : Bool
    }


initModel : Model
initModel =
    { flip = True
    }


type Msg
    = Flip


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Flip ->
            ( { model | flip = not model.flip }, Cmd.none )


{-| -}
introspection :
    { boxed : Bool
    , description : String
    , name : String
    , signature : String
    , usage : String
    , usageResult : Element msg
    , variations : List ( String, List ( Element msg1, String ) )
    }
introspection =
    { name = "Cards"
    , signature = "simpleWithTitle : String -> String -> Element msg -> Element msg"
    , description = "Wrapper for content"
    , usage = """simpleWithTitle "Simple" "with Title" (text "Content")"""
    , usageResult = simpleWithTitle "Simple" "with Title" (text "Content")
    , boxed = False
    , variations =
        [ ( "Flipping", [ ( text "special: Cards.example1", "" ) ] )
        , ( "Simple with Title", [ ( simpleWithTitle "Simple" "with Title" <| text "Content", """simpleWithTitle "Simple" "with Title" <|
text "Content\"""" ) ] )
        , ( "Simple", [ ( simple <| text "Content", """simple <| text "Content\"""" ) ] )
        ]

    --, variations =
    --    [ "Variations"
    --, [ ( simpleWithTitle "Simple" "with Title" <| text "Content", """simpleWithTitle "Simple" "with Title" <|
    --text "Content\"""" )
    --, ( simple <| text "Content", """simple <|
    --text "Content\"""" )
    --        [ ( "Credit Card number", [ ( text "special: Form.example2", "" ) ] ) ]
    --    ]
    }


cardCommonAttr : List (Attribute msg)
cardCommonAttr =
    [ Border.shadow { blur = 10, color = Color.rgba 0 0 0 0.05, offset = ( 0, 2 ), size = 1 }
    , Border.width 1
    , Border.color <| color GrayLighter
    , Background.color <| color White
    , Border.rounded 4
    ]


example1 : { a | flip : Bool } -> ( Element Msg, String )
example1 model =
    let
        commonAttr =
            [ height fill
            , pointer
            , Events.onClick Flip
            ]

        contentAttr =
            [ width shrink
            , height shrink
            , centerX
            , centerY
            , spacing 50
            ]
    in
    ( flipping
        { width = 200
        , height = 300
        , activeFront = model.flip
        , front =
            el commonAttr <|
                column contentAttr
                    [ el [ centerX ] <| text "Click Me"
                    , el [ centerX ] <| text "Front"
                    ]
        , back =
            el (commonAttr ++ [ Background.color Color.yellow ]) <|
                column contentAttr
                    [ el [ centerX ] <| text "Click Me"
                    , el [ centerX ] <| text "Back"
                    ]
        }
    , """
flipping
    { width = 200
    , height = 300
    , activeFront = model.flip
    , front =
        el commonAttr <|
            column contentAttr
                [ el [ centerX ] <| text "Click Me"
                , el [ centerX ] <| text "Front"
                ]
    , back =
        el (commonAttr ++ [ Background.color Color.yellow ]) <|
            column contentAttr
                [ el [ centerX ] <| text "Click Me"
                , el [ centerX ] <| text "Back"
                ]
    }"""
    )


simpleWithTitle : String -> String -> Element msg -> Element msg
simpleWithTitle title subTitle content =
    column
        (cardCommonAttr
            ++ [ Border.width 1
               , width fill
               , height shrink
               ]
        )
        [ el
            [ padding 10
            , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Border.color <| color GrayLight
            , width fill
            ]
            (paragraph [ spacing 10 ]
                [ el [ Font.bold ] <| text title
                , el [ Font.color <| color GrayMedium ] <| text subTitle
                ]
            )
        , el [ padding 20, width fill ] content
        ]


simple : Element msg -> Element msg
simple content =
    el
        (cardCommonAttr
            ++ [ padding 20
               , width fill
               , height shrink
               ]
        )
    <|
        content


flipping :
    { a
        | activeFront : Bool
        , back : Element msg
        , front : Element msg
        , height : Int
        , width : Int
    }
    -> Element msg
flipping data =
    let
        x =
            px data.width

        y =
            px data.height

        commonAttr =
            cardCommonAttr
                ++ [ width x
                   , height y
                   , style "backface-visibility" "hidden"
                   , style "position" "absolute"
                   ]
    in
    el
        [ style "perspective" "500px"
        , alignTop
        ]
    <|
        column
            [ width <| x
            , height <| y
            , style "transition" "0.4s"
            , style "transform-style" "preserve-3d"
            , case data.activeFront of
                True ->
                    style "transform" "rotateY(0deg)"

                False ->
                    style "transform" "rotateY(180deg)"
            ]
            [ -- The  "alignbottom {pointer-events:none}" is needed otherwise the right half
              -- is covered by alignbottom
              html <| Html.node "style" [] [ Html.text "alignbottom {pointer-events:none}" ]
            , el
                (commonAttr
                    ++ [ style "transform" "rotateY(0deg)"
                       , style "z-index" "2"
                       ]
                )
              <|
                data.front
            , el
                (commonAttr
                    ++ [ style "transform" "rotateY(180deg)"
                       ]
                )
              <|
                data.back
            ]


style : String -> String -> Attribute msg
style key value =
    if Regex.contains (Regex.regex <| "|" ++ key ++ "|") "|backface-visibility|perspective|transition|transform-style|transform|" then
        htmlAttribute <|
            Html.Attributes.style
                [ ( "-webkit-" ++ key, value )
                , ( "-moz-" ++ key, value )
                , ( "-ms-" ++ key, value )
                , ( "-o-" ++ key, value )
                , ( key, value )
                ]
    else
        htmlAttribute <| Html.Attributes.style [ ( key, value ) ]

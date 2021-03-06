module Decoder exposing (shapesDecoder, userDecoder, uploadDecoder)

import Json.Decode exposing (..)
import Json.Decode.Pipeline
    exposing
        ( decode
        , required
        , custom
        )
import Model
    exposing
        ( Shape(..)
        , RectModel
        , CircleModel
        , TextModel
        , ImageModel
        , User
        , Upload(..)
        )
import Dict exposing (Dict)


shapesDecoder : Decoder (Dict Int Shape)
shapesDecoder =
    dict shapeDecoder
        |> map parseIntKeys


parseIntKeys : Dict String Shape -> Dict Int Shape
parseIntKeys stringShapes =
    stringShapes
        |> Dict.toList
        |> List.map
            (\( k, v ) ->
                ( k |> String.toInt |> Result.withDefault 0
                , v
                )
            )
        |> Dict.fromList


shapeDecoder : Decoder Shape
shapeDecoder =
    field "type" string
        |> andThen specificShapeDecoder


specificShapeDecoder : String -> Decoder Shape
specificShapeDecoder typeStr =
    case typeStr of
        "rect" ->
            decode Rect
                |> custom rectModelDecoder

        "circle" ->
            decode Circle
                |> custom circleModelDecoder

        "text" ->
            decode Text
                |> custom textModelDecoder

        "image" ->
            decode Image
                |> custom imageModelDecoder

        _ ->
            fail "unknown shape type"


imageModelDecoder : Decoder ImageModel
imageModelDecoder =
    decode ImageModel
        |> required "x" float
        |> required "y" float
        |> required "width" float
        |> required "height" float
        |> required "href" string


rectModelDecoder : Decoder RectModel
rectModelDecoder =
    decode RectModel
        |> required "x" float
        |> required "y" float
        |> required "width" float
        |> required "height" float
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


circleModelDecoder : Decoder CircleModel
circleModelDecoder =
    decode CircleModel
        |> required "cx" float
        |> required "cy" float
        |> required "r" float
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


textModelDecoder : Decoder TextModel
textModelDecoder =
    decode TextModel
        |> required "x" float
        |> required "y" float
        |> required "content" string
        |> required "fontFamily" string
        |> required "fontSize" int
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "displayName" string
        |> required "email" string
        |> required "photoURL" string


uploadDecoder : Decoder Upload
uploadDecoder =
    -- We'll use `oneOf`, which will try different decoders until it finds a
    -- successful decoder.
    oneOf <|
        -- Then we'll look at each possible shape and decode them appropriately
        [ field "running" <| map Running float
        , field "error" <| map Errored string
        , field "paused" <| map Paused float
        , field "complete" <| map Completed string
        ]

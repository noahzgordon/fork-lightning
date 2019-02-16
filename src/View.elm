module View exposing (draw)

import Color exposing (rgb)
import Html exposing (Html)
import Messages exposing (Message)
import Model exposing (..)
import TypedSvg exposing (..)
import TypedSvg.Attributes as Attributes exposing (..)
import TypedSvg.Core exposing (..)
import TypedSvg.Types exposing (..)


draw : Model -> List (Html Message)
draw model =
    [ svg
        [ width (model.window.width |> px)
        , height (model.window.height |> px)
        , Attributes.style "position: absolute; top: 0; left: 0;"
        ]
        [ rect
            [ width (100 |> percent)
            , height (100 |> percent)
            , fill (rgb 0 0 0 |> Fill)
            ]
            []
        ]
    ]

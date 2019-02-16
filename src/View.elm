module View exposing (draw)

import Html exposing (Html)
import Messages exposing (Message)
import Model exposing (..)


draw : Model -> List (Html Message)
draw model =
    [ Html.text "hello world" ]

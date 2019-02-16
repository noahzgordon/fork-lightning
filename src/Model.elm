module Model exposing (Model, init)

import Messages exposing (Message)


type alias Model =
    { window : Dimensions }


type alias Dimensions =
    { width : Float, height : Float }


type alias Flags =
    { window : Dimensions }


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { window = flags.window }, Cmd.none )

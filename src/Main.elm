module Main exposing (main)

import Browser
import Messages exposing (Message)
import Model exposing (Model)
import View


title =
    "Fork Lightning"


main =
    Browser.document
        { init = Model.init
        , view =
            \model ->
                { title = title
                , body = View.draw model
                }
        , update = update
        , subscriptions = subscriptions
        }


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none

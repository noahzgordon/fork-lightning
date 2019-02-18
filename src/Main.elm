module Main exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrame)
import Messages exposing (..)
import Model exposing (..)
import Random
import Time exposing (posixToMillis)
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
    case message of
        AnimationFrameTriggered time ->
            let
                seed0 =
                    Random.initialSeed (posixToMillis time)
            in
            ( { model | bolts = generateBolts seed0 model }
            , Cmd.none
            )


generateBolts : Random.Seed -> Model -> List Bolt
generateBolts seed model =
    if List.isEmpty model.bolts then
        [ makeNewBolt seed model ]

    else
        model.bolts


makeNewBolt : Random.Seed -> Model -> Bolt
makeNewBolt seed model =
    let
        ( coords, seed1 ) =
            Random.step (randomScreenPos model.window) seed

        ( length, seed2 ) =
            Random.step arcLength seed1

        ( angle, seed3 ) =
            Random.step (Random.float 0 360) seed2
    in
    { origin = coords
    , length = length
    , angle = angle
    }


randomScreenPos : Dimensions -> Random.Generator Coords
randomScreenPos dims =
    Random.map2 Coords
        (Random.float 100 (dims.width - 100))
        (Random.float 100 (dims.height - 100))


arcLength : Random.Generator Float
arcLength =
    Random.float 2 10


subscriptions : Model -> Sub Message
subscriptions model =
    onAnimationFrame AnimationFrameTriggered

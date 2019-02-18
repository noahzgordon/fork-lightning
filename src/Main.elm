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
        List.filterMap (iterateBolt seed) model.bolts


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
    , lifeTime = 1
    , arcs =
        [ Arc
            { length = length
            , angle = angle
            , arcs = []
            }
        ]
    }


iterateBolt : Random.Seed -> Bolt -> Maybe Bolt
iterateBolt seed bolt =
    let
        ( shouldSurvive, seed1 ) =
            Random.step
                (Random.weighted ( 1, True ) [ ( toFloat bolt.lifeTime / 500, False ) ])
                seed
    in
    if shouldSurvive then
        Just <|
            { bolt
                | lifeTime = bolt.lifeTime + 1
                , arcs = List.map (iterateArc seed1) bolt.arcs
            }

    else
        Nothing


iterateArc : Random.Seed -> Arc -> Arc
iterateArc seed (Arc arc) =
    if List.isEmpty arc.arcs then
        let
            ( length, seed1 ) =
                Random.step arcLength seed

            ( angle, seed2 ) =
                Random.step (Random.float (arc.angle - 1) (arc.angle + 1)) seed1
        in
        Arc
            { arc
                | arcs =
                    [ Arc
                        { length = length
                        , angle = angle
                        , arcs = []
                        }
                    ]
            }

    else
        Arc { arc | arcs = List.map (iterateArc seed) arc.arcs }


randomScreenPos : Dimensions -> Random.Generator Coords
randomScreenPos dims =
    Random.map2 Coords
        (Random.float 100 (dims.width - 100))
        (Random.float 100 (dims.height - 100))


arcLength : Random.Generator Float
arcLength =
    Random.float 4 20


subscriptions : Model -> Sub Message
subscriptions model =
    onAnimationFrame AnimationFrameTriggered

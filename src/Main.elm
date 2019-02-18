module Main exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrame)
import List.Extra as List
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

        ( arcProb, seed2 ) =
            Random.step probability seed

        arcNum =
            if arcProb > 0.95 then
                3

            else if arcProb > 0.8 then
                2

            else
                1

        ( arcVals, seed3 ) =
            Random.step
                (Random.list arcNum (Random.pair arcLength (Random.float 0 360)))
                seed2
    in
    { origin = coords
    , lifeTime = 1
    , arcs =
        List.map
            (\( length, angle ) ->
                Arc
                    { length = length
                    , angle = angle
                    , arcs = []
                    }
            )
            arcVals
    }


iterateBolt : Random.Seed -> Bolt -> Maybe Bolt
iterateBolt seed bolt =
    let
        ( survivalProb, seed1 ) =
            Random.step probability seed
    in
    if (survivalProb / toFloat bolt.lifeTime) >= 0.001 then
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


probability : Random.Generator Float
probability =
    Random.float 0 1


subscriptions : Model -> Sub Message
subscriptions model =
    onAnimationFrame AnimationFrameTriggered

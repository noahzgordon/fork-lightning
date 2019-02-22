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
                    , origAngle = angle
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
        let
            ( seeds, _ ) =
                Random.step
                    (Random.list (List.length bolt.arcs) Random.independentSeed)
                    seed1
        in
        Just <|
            { bolt
                | lifeTime = bolt.lifeTime + 1
                , arcs =
                    List.zip bolt.arcs seeds
                        |> List.map (\( arc, newSeed ) -> iterateArc newSeed arc)
            }

    else
        Nothing


iterateArc : Random.Seed -> Arc -> Arc
iterateArc seed (Arc arc) =
    if List.isEmpty arc.arcs then
        let
            ( arcProb, seed1 ) =
                Random.step probability seed

            arcNum =
                if arcProb > 0.99 then
                    2

                else
                    1

            ( arcVals, seed2 ) =
                Random.step
                    (Random.list arcNum (Random.pair arcLength (Random.float (arc.angle - 1.5) (arc.angle + 1.5))))
                    seed1
        in
        Arc
            { arc
                | arcs =
                    List.map
                        (\( length, angle ) ->
                            if arcNum == 1 then
                                Arc
                                    { length = length
                                    , angle = angle + ((arc.origAngle - angle) / 3)
                                    , origAngle = arc.origAngle
                                    , arcs = []
                                    }

                            else
                                Arc
                                    { length = length
                                    , angle = angle
                                    , origAngle = angle
                                    , arcs = []
                                    }
                        )
                        arcVals
            }

    else
        let
            ( seeds, _ ) =
                Random.step
                    (Random.list (List.length arc.arcs) Random.independentSeed)
                    seed
        in
        Arc
            { arc
                | arcs =
                    List.zip arc.arcs seeds
                        |> List.map (\( subArc, newSeed ) -> iterateArc newSeed subArc)
            }


randomScreenPos : Dimensions -> Random.Generator Coords
randomScreenPos dims =
    Random.map2 Coords
        (Random.float 100 (dims.width - 100))
        (Random.float 100 (dims.height - 100))


arcLength : Random.Generator Float
arcLength =
    Random.float 4 15


probability : Random.Generator Float
probability =
    Random.float 0 1


subscriptions : Model -> Sub Message
subscriptions model =
    onAnimationFrame AnimationFrameTriggered

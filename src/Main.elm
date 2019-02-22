module Main exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrame)
import Circle2d as Circle
import List.Extra as List
import Messages exposing (..)
import Model exposing (..)
import Point2d as Point
import Random
import Random.Extra as Random
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

        ModifierChanged mod val ->
            ( case mod of
                Fremulation ->
                    { model | fremulation = val }

                Chaos ->
                    { model | chaos = val }

                Dilation ->
                    { model | dilation = val }

                Zoom ->
                    { model | zoom = val }
            , Cmd.none
            )


generateBolts : Random.Seed -> Model -> List Bolt
generateBolts seed model =
    if List.isEmpty model.bolts then
        let
            ( boltPos, seed1 ) =
                Random.step (randomScreenPos model.window) seed
        in
        [ makeNewBolt model seed1 boltPos ]

    else
        let
            ( rawNewBoltProb, seed1 ) =
                Random.step probability seed

            newBoltProb =
                rawNewBoltProb * model.chaos * 2

            boltNum =
                if List.length model.bolts > 5 then
                    0

                else if newBoltProb > 0.99 then
                    1

                else
                    0

            currentBoltPositions =
                List.map .origin model.bolts

            ( newBoltVars, seed2 ) =
                Random.step
                    (Random.list boltNum
                        (Random.pair
                            Random.independentSeed
                            (randomScreenPosWithoutOverlap model.window currentBoltPositions 300)
                        )
                    )
                    seed1

            newBolts =
                List.map (\( newSeed, pos ) -> makeNewBolt model newSeed pos) newBoltVars
        in
        List.filterMap (iterateBolt model) (model.bolts ++ newBolts)


makeNewBolt : Model -> Random.Seed -> Coords -> Bolt
makeNewBolt model seed coords =
    let
        ( arcProbRaw, seed1 ) =
            Random.step probability seed

        arcProb =
            arcProbRaw * model.chaos * 2

        arcNum =
            if arcProb > 0.95 then
                3

            else if arcProb > 0.8 then
                2

            else
                1

        ( arcVals, seed2 ) =
            Random.step
                (Random.list arcNum (Random.pair (arcLength model) (Random.float 0 360)))
                seed1
    in
    { origin = coords
    , lifeTime = 1
    , seed = seed2
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


iterateBolt : Model -> Bolt -> Maybe Bolt
iterateBolt model bolt =
    let
        ( survivalProb, seed1 ) =
            Random.step probability bolt.seed
    in
    if bolt.lifeTime < round (60 * model.dilation) || (survivalProb * model.dilation / toFloat bolt.lifeTime) >= 0.1 then
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
                        |> List.map (\( arc, newSeed ) -> iterateArc model newSeed arc)
            }

    else
        Nothing


iterateArc : Model -> Random.Seed -> Arc -> Arc
iterateArc model seed (Arc arc) =
    if List.isEmpty arc.arcs then
        let
            ( rawArcProb, seed1 ) =
                Random.step probability seed

            arcProb =
                rawArcProb * model.fremulation * (11 / 10)

            arcNum =
                if arcProb > 0.99 then
                    2

                else
                    1

            ( arcVals, seed2 ) =
                Random.step
                    (Random.list arcNum (Random.pair (arcLength model) (Random.float (arc.angle - 1.5) (arc.angle + 1.5))))
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
                        |> List.map (\( subArc, newSeed ) -> iterateArc model newSeed subArc)
            }


randomScreenPos : Dimensions -> Random.Generator Coords
randomScreenPos dims =
    Random.map2 Coords
        (Random.float 100 (dims.width - 300))
        (Random.float 100 (dims.height - 100))


randomScreenPosWithoutOverlap : Dimensions -> List Coords -> Float -> Random.Generator Coords
randomScreenPosWithoutOverlap dims points distance =
    randomScreenPos dims
        |> Random.filter
            (\point ->
                not <|
                    List.any
                        (\{ x, y } ->
                            Circle.contains
                                (Point.fromCoordinates ( point.x, point.y ))
                                (Circle.withRadius distance <| Point.fromCoordinates ( x, y ))
                        )
                        points
            )


arcLength : Model -> Random.Generator Float
arcLength model =
    Random.float (8 * model.zoom + 1) (30 * model.zoom + 2)


probability : Random.Generator Float
probability =
    Random.float 0 1


subscriptions : Model -> Sub Message
subscriptions model =
    onAnimationFrame AnimationFrameTriggered

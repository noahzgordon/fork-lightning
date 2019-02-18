module View exposing (draw)

import Arc2d
import Color exposing (Color, rgb)
import Html exposing (Html)
import Messages exposing (Message)
import Model exposing (..)
import Point2d
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
        ([ rect
            [ width (100 |> percent)
            , height (100 |> percent)
            , fill (rgb 0 0 0 |> Fill)
            ]
            []
         ]
            ++ List.map drawBolt model.bolts
        )
    ]


drawBolt : Bolt -> Svg Message
drawBolt bolt =
    let
        ( endX, endY ) =
            Arc2d.with
                { centerPoint = Point2d.fromCoordinates ( bolt.origin.x, bolt.origin.y )
                , radius = bolt.length
                , startAngle = 0
                , sweptAngle = bolt.angle
                }
                |> Arc2d.endPoint
                |> Point2d.coordinates
    in
    line
        [ x1 (bolt.origin.x |> px)
        , y1 (bolt.origin.y |> px)
        , x2 (endX |> px)
        , y2 (endY |> px)
        , stroke boltColor
        ]
        []


boltColor : Color
boltColor =
    rgb 1 1 1

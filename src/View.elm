module View exposing (draw)

import EffectView
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Html exposing (Html)
import Messages exposing (..)
import Model exposing (Model)


mods =
    [ ( Fremulation, "fremulation", .fremulation )
    , ( Chaos, "chaos quotient", .chaos )
    , ( Dilation, "time dilation", .dilation )
    , ( Zoom, "zoominess", .zoom )
    ]


draw : Model -> List (Html Message)
draw model =
    [ layout [ width fill, height fill ] <|
        row [ width fill, height fill ]
            [ column [ width (px 200), height fill, spacing 50, padding 50 ] <|
                List.map (modSlider model) mods
            , el [ width fill, height fill ] <|
                html (EffectView.draw model)
            ]
    ]


modSlider model ( modifier, label, prop ) =
    el
        [ height (px 50)
        , width (px 150)
        , centerX
        ]
    <|
        Input.slider
            [ Element.behindContent
                (Element.el
                    [ Element.width Element.fill
                    , Element.height (Element.px 2)
                    , Element.centerY
                    , Background.color (rgb 0.5 0.5 0.5)
                    , Border.rounded 2
                    ]
                    Element.none
                )
            ]
            { onChange = ModifierChanged modifier
            , label = Input.labelAbove [] (text label)
            , min = 0
            , max = 1
            , value = prop model
            , thumb = Input.defaultThumb
            , step = Just 0.01
            }

module Model exposing (Arc(..), Bolt, Coords, Dimensions, Model, init)

import Messages exposing (Message)
import Point2d


type alias Model =
    { window : Dimensions
    , bolts : List Bolt
    }


type alias Dimensions =
    { width : Float, height : Float }


type alias Coords =
    { x : Float, y : Float }


type alias Flags =
    { window : Dimensions }


type alias Bolt =
    { origin : Coords
    , lifeTime : Int
    , arcs : List Arc
    }


type Arc
    = Arc ArcInfo


type alias ArcInfo =
    { length : Float
    , arcs : List Arc
    , angle : Float
    }


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { window = flags.window
      , bolts = []
      }
    , Cmd.none
    )

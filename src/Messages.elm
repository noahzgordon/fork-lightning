module Messages exposing (Message(..), Modifier(..))

import Time exposing (Posix)


type Modifier
    = Fremulation
    | Chaos
    | Dilation
    | Zoom


type Message
    = AnimationFrameTriggered Posix
    | ModifierChanged Modifier Float

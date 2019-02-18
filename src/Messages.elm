module Messages exposing (Message(..))

import Time exposing (Posix)


type Message
    = AnimationFrameTriggered Posix

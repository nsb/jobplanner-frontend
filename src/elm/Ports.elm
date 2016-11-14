port module Ports exposing (..)

-- import Work exposing (Recurrence)


port storeApiKey : String -> Cmd msg


port rruleToText : String -> Cmd msg


port rruleText : (String -> msg) -> Sub msg


port parseRRule : String -> Cmd msg



-- port receiveRRule : Recurrence -> Sub msg

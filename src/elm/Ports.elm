port module Ports exposing (..)

-- import Work exposing (Recurrence)


port storeApiKey : String -> Cmd msg


port rruleToText : String -> Cmd msg


port rruleText : (List String -> msg) -> Sub msg



-- port parseRRule : String -> Cmd msg
-- port receiveRRule : Recurrence -> Sub msg

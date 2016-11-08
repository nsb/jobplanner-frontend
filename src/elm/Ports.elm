port module Ports exposing (..)


port storeApiKey : String -> Cmd msg


port rruleToText : String -> Cmd msg


port rruleText : (String -> msg) -> Sub msg

module Work.Types exposing (..)

import Http exposing (Error)


type alias JobItem =
    { customer : String
    , recurrences : String
    , description : String
    }


type alias Model =
    { jobItems : Maybe (Result Error (List JobItem)) }


type Msg
    = LoadJobs (Result Error (List JobItem))
    | Reset

module Work.Rest exposing (..)

import Http exposing (Error)
import Json.Decode exposing (..)
import Task
import Work.Types exposing (..)


decodeJobItems : Decoder (List JobItem)
decodeJobItems =
    list decodeJobItem


decodeJobItem : Decoder JobItem
decodeJobItem =
    object3 JobItem
        ("customer" := string)
        ("recurrences" := string)
        ("description" := string)


loadJobs : Cmd (Result Error (List JobItem))
loadJobs =
    Http.get decodeJobItems "http://localhost:8000/jobs/"
        |> Task.perform Err Ok

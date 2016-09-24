module Work.State exposing (init, update, subscriptions)

import Work.Types exposing (..)
import Work.Rest exposing (loadJobs)


init : ( Model, Cmd Msg )
init =
    ( { jobItems = Nothing }
    , Cmd.map LoadJobs loadJobs
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reset ->
            ( model
            , Cmd.none
            )

        LoadJobs response ->
            ( { model | jobItems = Just response }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

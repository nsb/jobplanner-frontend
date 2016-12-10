module Work exposing (..)

import Json.Decode as JsonD exposing (field)
import Html exposing (..)
import Html.Attributes exposing (..)
import Jwt
import Ports
import Date exposing (Date)
import String
import Ui.Button
import Ui.Loader


type alias JobItemId =
    Int


type Repeat
    = Daily
    | Weekly
    | Monthly
    | Yearly


type RepeatBy
    = Week
    | Month


type RecurrenceEnds
    = Never
    | Occurrences Int
    | OnDate Date


type alias Reccurence =
    { repeat : Repeat
    , every : Int
    , by : RepeatBy
    , begins : Date
    , ends : RecurrenceEnds
    }


type alias JobItem =
    { id : JobItemId
    , customer : Int
    , recurrences : String
    , recurrencesText : List String
    , description : String
    }


type alias Model =
    { jobItems : List JobItem
    , loading : Bool
    }


initialModel : Model
initialModel =
    { jobItems = []
    , loading = False
    }


type Msg
    = FetchData
    | FetchSucceed (Result Jwt.JwtError (List JobItem))
    | FetchFail String
    | Click
    | RRuleText (List String)


decodeJobItems : JsonD.Decoder (List JobItem)
decodeJobItems =
    JsonD.list decodeJobItem


decodeJobItem : JsonD.Decoder JobItem
decodeJobItem =
    JsonD.map5 JobItem
        (field "id" JsonD.int)
        (field "customer" JsonD.int)
        (field "recurrences" JsonD.string)
        (JsonD.succeed [])
        (field "description" JsonD.string)


loadJobs : String -> Cmd Msg
loadJobs token =
    Jwt.get token "http://localhost:8000/jobs/" decodeJobItems
        |> Jwt.sendCheckExpired token FetchSucceed


init : String -> ( Model, Cmd Msg )
init token =
    (initialModel ! [ loadJobs token ])


getRRuleText : List JobItem -> Cmd Msg
getRRuleText jobItems =
    Cmd.batch (List.map (\j -> Ports.rruleToText j.recurrences) jobItems)


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        FetchData ->
            ( { model | loading = True }, loadJobs token )

        FetchSucceed res ->
            case res of
                Result.Ok jobs ->
                    ( { model | jobItems = jobs, loading = False }
                    , getRRuleText jobs
                    )

                Result.Err _ ->
                    ( model, Cmd.none )

        FetchFail error ->
            ( { model | loading = False }, Cmd.none )

        Click ->
            ( model, Cmd.none )

        RRuleText rules ->
            let
                updateJobItem jobItem =
                    { jobItem | recurrencesText = rules }
            in
                ( { model | jobItems = List.map updateJobItem model.jobItems }
                , Cmd.none
                )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ Ports.rruleText RRuleText ]


loading : Html msg
loading =
    Ui.Loader.barView { timeout = 1000, loading = True, shown = True }


list : List JobItem -> Html Msg
list jobs =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Customer" ]
                    , th [] [ text "Recurrence" ]
                    , th [] [ text "Recurrence" ]
                    , th [] [ text "Description" ]
                    ]
                ]
            , tbody [] (List.map jobRow jobs)
            ]
        ]


jobRow : JobItem -> Html Msg
jobRow job =
    tr []
        [ td [] [ text (toString job.id) ]
        , td [] [ text (toString job.customer) ]
        , td [] [ text job.recurrences ]
        , td [] [ text (String.concat job.recurrencesText) ]
        , td [] [ text job.description ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ h4 [] [ text "Jobs" ]
        , p []
            [ case model.loading of
                True ->
                    loading

                False ->
                    list model.jobItems
            ]
        , Ui.Button.primary "Add" Click
        ]

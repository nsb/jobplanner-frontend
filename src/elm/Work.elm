module Work exposing (..)

import Json.Decode as JsonD exposing ((:=))
import Task
import Html exposing (..)
import Html.Attributes exposing (..)
import Jwt


type alias JobItem =
    { customer : String
    , recurrences : String
    , description : String
    }


type alias Model =
    { jobItems : List JobItem }


initialModel : Model
initialModel =
    { jobItems = [] }


type Msg
    = FetchData
    | FetchSucceed (List JobItem)
    | FetchFail String


decodeJobItems : JsonD.Decoder (List JobItem)
decodeJobItems =
    JsonD.list decodeJobItem


decodeJobItem : JsonD.Decoder JobItem
decodeJobItem =
    JsonD.object3 JobItem
        ("customer" := JsonD.string)
        ("recurrences" := JsonD.string)
        ("description" := JsonD.string)


loadJobs : String -> Cmd Msg
loadJobs token =
    Jwt.get token decodeJobItems "http://localhost:8000/jobs/"
        |> Task.mapError toString
        |> Task.perform FetchFail FetchSucceed


init : String -> ( Model, Cmd Msg )
init token =
    (initialModel ! [ loadJobs token ])


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        FetchData ->
            ( model, loadJobs token )

        FetchSucceed jobs ->
            ( { model | jobItems = jobs }, Cmd.none )

        FetchFail error ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


loading : Html msg
loading =
    div [ class "loading" ]
        [ img
            [ src "loading_wheel.gif"
            , class "loading"
            ]
            []
        ]


view : Model -> Html Msg
view model =
    div []
        [ h4 [] [ text "Cell 4" ]
        , p [] [ text "Size varies with device" ]
        ]

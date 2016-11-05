module Work exposing (..)

import Json.Decode as JsonD exposing ((:=))
import Task
import Html exposing (..)
import Html.Attributes exposing (..)
import Jwt
import Material
import Material.Button as Button exposing (..)
import Material.Icon as Icon
import Material.Spinner as Loading
import Debug


type alias JobItemId =
    Int


type alias JobItem =
    { id : JobItemId
    , customer : Int
    , recurrences : String
    , description : String
    }


type alias Model =
    { jobItems : List JobItem
    , loading : Bool
    , mdl : Material.Model
    }


initialModel : Model
initialModel =
    { jobItems = []
    , mdl = Material.model
    , loading = False
    }


type Msg
    = FetchData
    | FetchSucceed (List JobItem)
    | FetchFail String
    | Mdl (Material.Msg Msg)
    | Click


decodeJobItems : JsonD.Decoder (List JobItem)
decodeJobItems =
    JsonD.list decodeJobItem


decodeJobItem : JsonD.Decoder JobItem
decodeJobItem =
    JsonD.object4 JobItem
        ("id" := JsonD.int)
        ("customer" := JsonD.int)
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
            ( { model | loading = True }, loadJobs token )

        FetchSucceed jobs ->
            ( { model | jobItems = jobs, loading = False }, Cmd.none )

        FetchFail error ->
            ( { model | loading = False }, Cmd.none )

        Mdl msg' ->
            Material.update msg' model

        Click ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type alias Mdl =
    Material.Model


loading : Html msg
loading =
    div [ class "loading" ]
        [ Loading.spinner
            [ Loading.active True ]
        ]


list : List JobItem -> Html Msg
list jobs =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Customer" ]
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
        , td [] [ text job.description ]
        ]


view : Model -> Material.Model -> Html Msg
view model mdl =
    div []
        [ h4 [] [ text "Jobs" ]
        , p []
            [ case model.loading of
                True ->
                    loading

                False ->
                    list model.jobItems
            ]
        , Button.render Mdl
            [ 0 ]
            mdl
            [ Button.fab
            , Button.colored
            , Button.ripple
            , Button.onClick Click
            ]
            [ Icon.i "add" ]
        ]

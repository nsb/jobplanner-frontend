module Main exposing (..)

import Html exposing (..)
import Ui.App
import Ui.Layout
import Ui.Header
import Work
import Login
import Routing exposing (Route(..), parseLocation)
import Navigation exposing (Location)


-- MODEL


type alias ProgramFlags =
    { apiKey : Maybe String
    }


type Section
    = Calendar
    | Clients
    | Work


type alias Model =
    { app : Ui.App.Model
    , currentSection : Section
    , workModel : Work.Model
    , loginModel : Login.Model
    , route : Routing.Route
    }


initialModel : Route -> Model
initialModel route =
    Model Ui.App.init Work Work.initialModel Login.initialModel route


init : ProgramFlags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            parseLocation location

        modelWithRoute =
            initialModel currentRoute

        updatedModel =
            { modelWithRoute | loginModel = Login.updateModelWithToken flags.apiKey }
    in
        case updatedModel.loginModel.token of
            Just apiKey ->
                ( updatedModel, Cmd.map WorkMessage (Work.loadJobs apiKey) )

            Nothing ->
                ( updatedModel, Cmd.none )



-- ACTION, UPDATE


type Msg
    = App Ui.App.Msg
    | ChangeSection Section
    | WorkMessage Work.Msg
    | LoginMessage Login.Msg
    | OnLocationChange Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeSection msg_ ->
            ( { model | currentSection = msg_ }, Cmd.none )

        WorkMessage msg_ ->
            case model.loginModel.token of
                Just token ->
                    let
                        ( subMdl, subCmd ) =
                            Work.update msg_ model.workModel token
                    in
                        ( { model | workModel = subMdl }, Cmd.map WorkMessage subCmd )

                Nothing ->
                    ( model, Cmd.none )

        LoginMessage msg_ ->
            let
                ( subMdl, subCmd ) =
                    Login.update msg_ model.loginModel
            in
                ( { model | loginModel = subMdl }, Cmd.map LoginMessage subCmd )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        App act ->
            let
                ( app, effect ) =
                    Ui.App.update act model.app
            in
                ( { model | app = app }, Cmd.map App effect )



-- VIEW


content : Model -> Html Msg
content model =
    case model.route of
        JobsRoute ->
            Html.map WorkMessage (Work.view model.workModel)

        JobRoute id ->
            text "JobRoute"

        Login ->
            Html.map LoginMessage (Login.view model.loginModel)

        NotFoundRoute ->
            text "NotFoundRoute"


sidebar : Html Msg
sidebar =
    div []
        [ Ui.Header.view
            [ Ui.Header.title
                { action = Nothing
                , target = "_self"
                , link = Nothing
                , text = ""
                }
            ]
        , div [] [ text "sidebar 1" ]
        , div [] [ text "sidebar 2" ]
        , div [] [ text "sidebar 3" ]
        ]


header : Html Msg
header =
    Ui.Header.view
        [ Ui.Header.title
            { action = Nothing
            , target = "_self"
            , link = Nothing
            , text = "JobPlanner"
            }
        ]


authenticated : Model -> Html Msg
authenticated model =
    Ui.App.view App
        model.app
        [ Ui.Layout.app
            [ sidebar ]
            [ header ]
            [ content model ]
        ]


unauthenticated : Model -> Html Msg
unauthenticated model =
    Ui.App.view App
        model.app
        [ Ui.Layout.website
            [ header ]
            [ content model ]
            [ text "footer" ]
        ]


view : Model -> Html Msg
view model =
    case model.route of
        Login ->
            unauthenticated model

        _ ->
            authenticated model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Sub.map WorkMessage (Work.subscriptions model.workModel) ]


main : Program ProgramFlags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }

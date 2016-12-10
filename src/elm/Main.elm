module Main exposing (..)

import Html exposing (..)
import Ui.App
import Ui.Layout
import Ui.Header
import Work
import Login
import Signup
import Routing exposing (Route(..), parseLocation)
import Navigation exposing (Location, newUrl)


-- MODEL


type alias ProgramFlags =
    { apiKey : Maybe String
    }


type alias Model =
    { app : Ui.App.Model
    , workModel : Work.Model
    , loginModel : Login.Model
    , signupModel : Signup.Model
    , route : Routing.Route
    }


initialModel : Route -> Model
initialModel route =
    Model
        Ui.App.init
        Work.initialModel
        Login.initialModel
        Signup.initialModel
        route


init : ProgramFlags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            parseLocation location

        modelWithRoute =
            initialModel currentRoute

        updatedModel =
            { modelWithRoute
                | loginModel =
                    Login.updateModelWithToken flags.apiKey
            }
    in
        ( updatedModel
        , cmdForRoute updatedModel.route updatedModel.loginModel.token
        )



-- ACTION, UPDATE


type Msg
    = App Ui.App.Msg
    | WorkMessage Work.Msg
    | LoginMessage Login.Msg
    | SignupMessage Signup.Msg
    | OnLocationChange Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        SignupMessage msg_ ->
            let
                ( subMdl, subCmd ) =
                    Signup.update msg_ model.signupModel
            in
                ( { model | signupModel = subMdl }, Cmd.map SignupMessage subCmd )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }
                , cmdForRoute newRoute model.loginModel.token
                )

        App act ->
            let
                ( app, effect ) =
                    Ui.App.update act model.app
            in
                ( { model | app = app }, Cmd.map App effect )


cmdForRoute : Route -> Maybe String -> Cmd Msg
cmdForRoute route apiKey =
    case apiKey of
        Just apiKey_ ->
            case route of
                JobsRoute ->
                    Cmd.map WorkMessage (Work.loadJobs apiKey_)

                _ ->
                    Cmd.none

        Nothing ->
            newUrl "#login"



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

        Signup ->
            Html.map SignupMessage (Signup.view model.signupModel)

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

        Signup ->
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

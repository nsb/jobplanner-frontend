module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, class, style, colspan)
import Ui.App
import Ui.Layout
import Ui.Header
import Ui.Container
import Material
import Material.Layout as Layout
import Material.Color exposing (Hue(..))
import Material.Scheme as Scheme
import Material.Grid exposing (grid, cell, size, offset, Device(..))
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
    { mdl :
        Material.Model
    , app : Ui.App.Model
    , currentSection : Section
    , workModel : Work.Model
    , loginModel : Login.Model
    , route : Routing.Route
    }


initialModel : Route -> Model
initialModel route =
    Model Material.model Ui.App.init Work Work.initialModel Login.initialModel route


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
    = Mdl (Material.Msg Msg)
    | App Ui.App.Msg
    | ChangeSection Section
    | WorkMessage Work.Msg
    | LoginMessage Login.Msg
    | OnLocationChange Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg_ ->
            Material.update msg_ model

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


type alias Mdl =
    Material.Model


content : Model -> Html Msg
content model =
    case model.route of
        JobsRoute ->
            Html.map WorkMessage (Work.view model.workModel model.mdl)

        JobRoute id ->
            text "JobRoute"

        Login ->
            Html.map LoginMessage (Login.view model.loginModel)

        NotFoundRoute ->
            text "NotFoundRoute"


componentHeader : String -> Html.Html Msg
componentHeader title =
    componentHeaderRender title


componentHeaderRender : String -> Html.Html Msg
componentHeaderRender title =
    tr [] [ td [ colspan 3 ] [ text title ] ]


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


view : Model -> Html Msg
view model =
    Ui.App.view App
        model.app
        [ Ui.Layout.app
            [ sidebar ]
            [ header ]
            [ content model ]
        ]



-- div []
--     [ Html.text ""
--     , Html.header [ Html.Attributes.title "JobPlanner" ] []
--     , Layout.render Mdl
--         model.mdl
--         [ Layout.fixedHeader
--         , Layout.fixedTabs
--         , Layout.waterfall True
--         ]
--         { header = [ header ]
--         , drawer = drawer
--         , tabs = ( [], [] )
--         , main =
--             [ content model
--             ]
--         }
--     ]
--     |> Scheme.topWithScheme Material.Color.Blue Material.Color.Green
-- urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
-- urlUpdate result model =
--     let
--         currentRoute =
--             Routing.routeFromResult result
--     in
--         ( { model | route = currentRoute }, Cmd.none )


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

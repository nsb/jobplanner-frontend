module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Ui.Container
import Ui.Button
import Ui.App
import Ui
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
    , currentSection : Section
    , workModel : Work.Model
    , loginModel : Login.Model
    , route : Routing.Route
    }


initialModel : Route -> Model
initialModel route =
    Model Material.model Work Work.initialModel Login.initialModel route


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



-- VIEW


type alias Mdl =
    Material.Model


page : Model -> Html Msg
page model =
    case model.route of
        JobsRoute ->
            Html.map WorkMessage (Work.view model.workModel model.mdl)

        JobRoute id ->
            text "JobRoute"

        Login ->
            Html.map LoginMessage (Login.view model.loginModel)

        NotFoundRoute ->
            text "NotFoundRoute"


drawer : List (Html Msg)
drawer =
    [ Layout.title [] [ text "JobPlanner" ]
    , Layout.navigation
        []
        [ Layout.link
            [ Layout.href "/calendar" ]
            [ text "Calendar" ]
        , Layout.link
            [ Layout.href "/clients" ]
            [ text "Clients" ]
        , Layout.link
            [ Layout.href "/jobs"
            , Layout.onClick (Layout.toggleDrawer Mdl)
            ]
            [ text "Work" ]
        ]
    ]


header : Html Msg
header =
    Layout.row []
        [ Layout.title [] [ text "JobPlanner" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link [ Layout.href "https://www.jobplanner.dk" ]
                [ text "JobPlanner" ]
            ]
        ]


content : Model -> Html Msg
content model =
    grid []
        [ cell [ size Tablet 8, size Desktop 12, size Phone 4 ]
            [ div []
                -- [ App.map WorkMessage (Work.view model.workModel)
                -- ]
                [ page model ]
              -- [ App.map LoginMessage (Login.view model.loginModel) ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ Html.text ""
        , Html.header [ Html.Attributes.title "JobPlanner" ] []
        , Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.fixedTabs
            , Layout.waterfall True
            ]
            { header = [ header ]
            , drawer = drawer
            , tabs = ( [], [] )
            , main =
                [ content model
                ]
            }
        ]
        |> Scheme.topWithScheme Material.Color.Blue Material.Color.Green



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

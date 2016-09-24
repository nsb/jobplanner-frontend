module Main exposing (..)

import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Material
import Material.Layout as Layout
import Material.Color exposing (Hue(..))
import Material.Scheme as Scheme
import Material.Grid exposing (grid, cell, size, offset, Device(..))
import Work.View
import Work.Types
import Work.State


-- MODEL


type Section
    = Calendar
    | Clients
    | Work


type alias Model =
    { mdl :
        Material.Model
    , currentSection : Section
    , workModel : Work.Types.Model
    }


model : Model
model =
    { mdl = Material.model
    , currentSection = Work
    , workModel = { jobItems = Nothing }
    }



-- ACTION, UPDATE


type Msg
    = Mdl (Material.Msg Msg)
    | ChangeSection Section
    | WorkMessage Work.Types.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg' ->
            Material.update msg' model

        ChangeSection msg' ->
            ( { model | currentSection = msg' }, Cmd.none )

        WorkMessage msg' ->
            let
                ( subMdl, subCmd ) =
                    Work.State.update msg' model.workModel
            in
                { model | workModel = subMdl }
                    ! [ Cmd.map WorkMessage subCmd ]



-- VIEW


type alias Mdl =
    Material.Model


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
            [ Layout.href "#work"
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


content : Model -> Html a
content model =
    grid []
        [ cell [ size Tablet 8, size Desktop 12, size Phone 4 ]
            [ Work.View.render
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


main : Program Never
main =
    App.program
        { init = ( model, Cmd.none )
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }

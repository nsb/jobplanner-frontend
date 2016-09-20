module Main exposing (..)

import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Material
import Material.Layout as Layout
import Material.Color exposing (Hue(..))
import Material.Scheme as Scheme
import Material.Grid exposing (grid, cell, size, offset, Device(..))


-- MODEL


type alias Model =
    { mdl :
        Material.Model
    }


model : Model
model =
    { mdl =
        Material.model
    }



-- ACTION, UPDATE


type Msg
    = Mdl (Material.Msg Msg)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg' ->
            Material.update msg' model



-- VIEW


type alias Mdl =
    Material.Model


drawer : List (Html Msg)
drawer =
  [ Layout.title [] [ text "JobPlanner" ]
  , Layout.navigation
    []
    [  Layout.link
        [ Layout.href "/calendar" ]
        [ text "Calendar" ]
    , Layout.link
        [ Layout.href "/clients" ]
        [ text "Clients" ]
    , Layout.link
        [ Layout.href "/work"
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


content : (Html a)
content =
  grid []
    [ cell [ size Tablet 8, size Desktop 12, size Phone 4 ]
        [ h4 [] [text "Cell 4"]
        , p [] [text "Size varies with device"]
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
                [ content
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

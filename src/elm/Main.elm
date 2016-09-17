module Main exposing (..)

import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Material
import Material.Layout as Layout
import Material.Color exposing (Hue(..))
import Material.Scheme as Scheme


-- MODEL


type alias Model =
    { count : Int
    , mdl :
        Material.Model
        -- Boilerplate: model store for any and all Mdl components you use.
    }


model : Model
model =
    { count = 0
    , mdl =
        Material.model
        -- Boilerplate: Always use this initial Mdl model store.
    }



-- ACTION, UPDATE


type Msg
    = Increase
    | Reset
    | Mdl (Material.Msg Msg)



-- Boilerplate: Msg clause for internal Mdl messages.


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increase ->
            ( { model | count = model.count + 1 }
            , Cmd.none
            )

        Reset ->
            ( { model | count = 0 }
            , Cmd.none
            )

        -- Boilerplate: Mdl action handler.
        Mdl msg' ->
            Material.update msg' model



-- VIEW


type alias Mdl =
    Material.Model


header : Html Msg
header =
    Layout.row []
        [ Layout.title [] [ text "JobPlanner" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link [ Layout.href "https://elm-lang.org/" ]
                [ text "elm-lang.org" ]
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
            , drawer = [ text "davs" ]
            , tabs = ( [], [] )
            , main =
                [ Html.text "hejsa"
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

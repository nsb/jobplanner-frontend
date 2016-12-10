module Signup exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Ui.Container


type alias Model =
    {}


initialModel : Model
initialModel =
    {}


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


type Msg
    = Signup


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Ui.Container.view
        { direction = "column", align = "center", compact = False }
        [ style [ ( "align-items", "center" ), ( "padding", "0 40px" ) ] ]
        [ div [] [ text "signup" ]
        ]

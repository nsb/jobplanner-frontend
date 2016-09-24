module Work.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


loading : Html msg
loading =
    div [ class "loading" ]
        [ img
            [ src "loading_wheel.gif"
            , class "loading"
            ]
            []
        ]


render : Html msg
render =
    div []
        [ h4 [] [ text "Cell 4" ]
        , p [] [ text "Size varies with device" ]
        ]

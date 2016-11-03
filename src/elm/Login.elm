module Login exposing (init, updateModelWithToken, update, view, Model, initialModel, Msg)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as E
import Platform.Cmd exposing (Cmd)
import Task exposing (toResult)
import Jwt exposing (..)
import Decoders exposing (..)
import Http exposing (empty)
import Ports


-- MODEL


type Field
    = Uname
    | Pword


type alias Model =
    { uname : String
    , pword : String
    , token : Maybe String
    , msg : String
    }


initialModel : Model
initialModel =
    Model "niels" "testpassword" Nothing ""


updateModelWithToken : Maybe String -> Model
updateModelWithToken token =
    { initialModel | token = token }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type
    Msg
    -- User generated Msg
    = FormInput Field String
    | Submit
    | TryToken
      -- Cmd results
    | LoginSuccess String
    | LoginFail JwtError
    | PostSucess String
    | PostFail JwtError


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormInput inputId val ->
            let
                res =
                    case inputId of
                        Uname ->
                            { model | uname = val }

                        Pword ->
                            { model | pword = val }
            in
                ( res, Cmd.none )

        Submit ->
            let
                credentials =
                    E.object
                        [ ( "username", E.string model.uname )
                        , ( "password", E.string model.pword )
                        ]
                        |> E.encode 0
            in
                ( model
                , authenticate tokenStringDecoder "http://localhost:8000/api-token-auth/" credentials
                    |> Task.perform LoginFail LoginSuccess
                )

        TryToken ->
            ( model
            , case model.token of
                Nothing ->
                    Cmd.none

                Just token ->
                    let
                        body =
                            (Http.string (E.encode 0 (E.object [ ( "token", E.string token ) ])))
                    in
                        Jwt.post token dataDecoder "http://localhost:8000/api-token-verify/" body
                            `Task.onError` (promote401 token)
                            |> Task.perform PostFail PostSucess
            )

        LoginSuccess token ->
            ( { model | token = Just token, msg = "" }, Ports.storeApiKey token )

        LoginFail err ->
            ( { model | msg = toString err }, Cmd.none )

        PostSucess msg ->
            ( { model | msg = msg }, Cmd.none )

        PostFail err ->
            ( { model | msg = toString err }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "container" ]
        [ h1 [] [ text "elm-jwt" ]
        , p [] [ text "username = niels, password = testpassword" ]
        , div
            [ class "row" ]
            [ Html.form
                [ onSubmit Submit
                , class "col-xs-12"
                ]
                [ div
                    []
                    [ div
                        [ class "form-group" ]
                        [ label
                            [ for "uname" ]
                            [ text "Username" ]
                        , input
                            -- [ on "input" (Json.map (Input Uname) targetValue) (Signal.message address)
                            [ onInput (FormInput Uname)
                            , class "form-control"
                            , id "uname"
                            , type' "text"
                            , value model.uname
                            ]
                            []
                        ]
                    , div
                        [ class "form-group" ]
                        [ label
                            [ for "pword" ]
                            [ text "Password" ]
                        , input
                            [ onInput (FormInput Pword)
                            , class "form-control"
                            , id "pword"
                            , type' "password"
                            , value model.pword
                            ]
                            []
                        ]
                    , button
                        [ type' "submit"
                        , class "btn btn-default"
                        ]
                        [ text "Submit" ]
                    ]
                ]
            ]
        , case model.token of
            Nothing ->
                text ""

            Just tokenString ->
                let
                    token =
                        decodeToken tokenDecoder tokenString
                in
                    div []
                        [ p [] [ text <| toString token ]
                        , button
                            [ class "btn btn-warning"
                            , onClick TryToken
                            ]
                            [ text "Try token" ]
                        ]
        , p
            [ style [ ( "color", "red" ) ] ]
            [ text model.msg ]
        ]



-- onSubmit' address Msg =
--     onWithOptions
--         "submit"
--         {stopPropagation = True, preventDefault = True}
--         (Json.succeed Msg)
--         (Signal.message address)
-- CMDS

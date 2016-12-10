module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Work exposing (JobItemId)


type Route
    = JobsRoute
    | JobRoute JobItemId
    | Login
    | Signup
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map JobsRoute (s "jobs")
        , map JobRoute (s "jobs" </> int)
        , map Login (s "login")
        , map Signup (s "signup")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

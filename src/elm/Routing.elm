module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Work exposing (JobItemId)


type Route
    = JobsRoute
    | JobRoute JobItemId
    | Login
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map JobsRoute (s "jobs")
        , map JobRoute (s "jobs" </> int)
        , map Login (s "login")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute



-- hashParser : Navigation.Location -> Result String Route
-- hashParser location =
--     location.hash
--         |> String.dropLeft 1
--         |> parse identity matchers
--
--
-- parser : Navigation.Parser (Result String Route)
-- parser =
--     Navigation.makeParser hashParser
-- routeFromResult : Result String Route -> Route
-- routeFromResult result =
--     case result of
--         Ok route ->
--             route
--
--         Err string ->
--             NotFoundRoute

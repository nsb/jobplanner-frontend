module Decoders exposing (..)

import Json.Decode as Json exposing (field, Value)


type alias JwtToken =
    { id : Int
    , username : String
    , email : String
    , expiry : Int
    }


tokenStringDecoder =
    (field "token" Json.string)


dataDecoder =
    (field "token" Json.string)


tokenDecoder =
    Json.oneOf
        [ djangoDecoder
        ]



-- nodeDecoder =
--     Json.object4 JwtToken
--         ("id" := Json.string)
--         ("username" := Json.string)
--         ("iat" := Json.int)
--         ("exp" := Json.int)


djangoDecoder =
    Json.map4 JwtToken
        (field "user_id" Json.int)
        (field "username" Json.string)
        (field "email" Json.string)
        (field "exp" Json.int)



-- phoenixDecoder =
--     Json.object4 JwtToken
--         ("aud" := Json.string)
--         ("aud" := Json.string)
--         ("iat" := Json.int)
--         ("exp" := Json.int)

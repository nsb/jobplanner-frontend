module Decoders exposing (..)

import Json.Decode as Json exposing ((:=), Value)


type alias JwtToken =
    { id : Int
    , username : String
    , email : String
    , expiry : Int
    }


tokenStringDecoder =
    ("token" := Json.string)


dataDecoder =
    ("token" := Json.string)


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
    Json.object4 JwtToken
        ("user_id" := Json.int)
        ("username" := Json.string)
        ("email" := Json.string)
        ("exp" := Json.int)



-- phoenixDecoder =
--     Json.object4 JwtToken
--         ("aud" := Json.string)
--         ("aud" := Json.string)
--         ("iat" := Json.int)
--         ("exp" := Json.int)

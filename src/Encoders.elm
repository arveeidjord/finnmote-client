module Encoders exposing (..)

-- import Time.DateTime as DateTime exposing (DateTime)
-- import Time.Iso8601 as Iso8601 exposing (..)

import Date exposing (..)
import Date.Extra.Format as Format exposing (format, formatUtc, isoMsecOffsetFormat)
import Json.Encode as Encoder
import Models exposing (Form, Token)
import Time exposing (Time)


clientId : String
clientId =
    "UjK2ISb0Bss3rQIgG2d7nroXalDs3cEW"


dbConnection : String
dbConnection =
    "db-connection"


signUp : Form -> Encoder.Value
signUp form =
    Encoder.object
        [ ( "navn", Encoder.string clientId )
        , ( "brukernavn", Encoder.string form.email )
        , ( "passord", Encoder.string form.password )
        ]


login : Form -> Encoder.Value
login form =
    Encoder.object
        [ -- ( "client_id", Encoder.string clientId )
          ( "passord", Encoder.string form.password )
        , ( "brukernavn", Encoder.string form.email )

        -- , ( "grant_type", Encoder.string "password" )
        -- , ( "audience", Encoder.string "elm-blog" )
        -- , ( "scope", Encoder.string "openid" )
        ]


postsQuery : Encoder.Value
postsQuery =
    Encoder.object
        [ ( "query", Encoder.string "query {allPosts(orderBy: createdAt_DESC){id title body}}" ) ]



--Blir til JSON:
-- {
-- 	"query" : "query {allPosts(orderBy: createdAt_DESC){id title body}}"
-- }


authenticate : Token -> Encoder.Value
authenticate token =
    let
        query =
            "mutation {authenticate (accessToken: \"" ++ token.accessToken ++ "\"){token}}"
    in
    Encoder.object
        [ ( "query", Encoder.string query ) ]


createPost : Form -> Encoder.Value
createPost form =
    Encoder.object
        [ ( "arrangoerId", Encoder.string "1" )
        , ( "beskrivelse", Encoder.string form.postBody )
        , ( "tidspunkt", Encoder.string (dateToIsoString form.date) )
        ]


dateToIsoString : Maybe Date -> String
dateToIsoString dato =
    case dato of
        Just dato ->
            Format.isoString dato

        Nothing ->
            ""



-- let
--     query =
--         "mutation {createPost(title: \"" ++ form.postTitle ++ "\" body: \"" ++ form.postBody ++ "\"" ++ "){id}}"
-- in
-- Encoder.object
--     [ ( "query", Encoder.string query ) ]

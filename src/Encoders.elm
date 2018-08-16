module Encoders exposing (..)

import Json.Encode as Encoder
import Models exposing (Form, Token)


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
    let
        query =
            "mutation {createPost(title: \"" ++ form.postTitle ++ "\" body: \"" ++ form.postBody ++ "\"" ++ "){id}}"
    in
    Encoder.object
        [ ( "query", Encoder.string query ) ]

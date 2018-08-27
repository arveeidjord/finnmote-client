module Api exposing (..)

import Decoders exposing (decodeArrangoerer, decodeGraphcoolToken, decodePosts, decodeToken, decodeUser)
import Encoders
import Http exposing (jsonBody, stringBody)
import Json.Decode
import Messages exposing (Msg)
import Models exposing (Arrangement, Form, Token, User)
import RemoteData


-- graphcool : String
-- graphcool =
--     "https://api.graph.cool/simple/v1/cjbm8w2980rge0186pld48aan"
-- domain : String
-- domain =
--     "https://nookit.eu.auth0.com"


domain : String
domain =
    "http://localhost:5000"


fetchAccount : Form -> Cmd Msg
fetchAccount user =
    Http.post (domain ++ "/users/register") (jsonBody <| Encoders.signUp user) (Json.Decode.succeed ())
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchAccount


fetchToken : Form -> Cmd Msg
fetchToken form =
    Http.post (domain ++ "/users/authenticate") (jsonBody <| Encoders.login form) decodeToken
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchToken


authorisedRequest : Token -> Http.Request User
authorisedRequest token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" <| "Bearer " ++ token.accessToken ]
        , url = domain ++ "/users/" ++ toString token.userId
        , body = Http.emptyBody
        , expect = Http.expectJson decodeUser
        , timeout = Nothing
        , withCredentials = False
        }


fetchUser : Token -> Cmd Msg
fetchUser token =
    authorisedRequest token
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchUser


fetchPosts : Cmd Msg
fetchPosts =
    Http.post (domain ++ "/api/arrangement/sok") (jsonBody <| Encoders.postsQuery) decodePosts
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchPosts


fetchArrangoerer : Cmd Msg
fetchArrangoerer =
    Http.get (domain ++ "/api/arrangoer") decodeArrangoerer
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchArrangoerer


createRequest : Form -> String -> Http.Request Arrangement
createRequest form token =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Authorization" <| "Bearer " ++ token ]
        , url = domain ++ "/api/arrangement"
        , body = Http.jsonBody <| Encoders.createPost form
        , expect = Http.expectJson Decoders.decodePost
        , timeout = Nothing
        , withCredentials = False
        }


createPost : Form -> Token -> Cmd Msg
createPost form token =
    createRequest form token.accessToken
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnCreatePost



-- authenticate : Token -> Cmd Msg
-- authenticate token =
--     Http.post (domain ++ "/api/arrangement/aaaaaaaaaaaaaaaaaaaaaaaaaa") (jsonBody <| Encoders.authenticate token) decodeGraphcoolToken
--         |> RemoteData.sendRequest
--         |> Cmd.map Messages.OnFetchGraphcoolToken

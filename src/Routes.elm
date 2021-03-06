module Routes exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = HomeRoute
    | ReadPostRoute Int
    | CreatePostRoute
    | LoginRoute
    | SignUpRoute
    | ErrorRoute


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            ErrorRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map HomeRoute (s "posts")
        , map ReadPostRoute (s "posts" </> int)
        , map CreatePostRoute (s "post")
        , map LoginRoute (s "login")
        , map SignUpRoute (s "signup")
        ]


path : Route -> String
path route =
    case route of
        HomeRoute ->
            "#"

        ReadPostRoute id ->
            "#posts/" ++ toString id

        CreatePostRoute ->
            "#post"

        LoginRoute ->
            "#login"

        SignUpRoute ->
            "#signup"

        ErrorRoute ->
            ""

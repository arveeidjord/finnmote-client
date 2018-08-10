-- landing : Model -> Html msg


module Pages exposing (..)

import Components exposing (..)
import Html exposing (Html, div)
import Messages exposing (Msg)
import Models exposing (..)
import RemoteData exposing (RemoteData(Failure, Loading, NotAsked, Success), WebData)
import Routes exposing (..)


landing : Model -> Html Msg
landing model =
    case model.posts of
        NotAsked ->
            div [] []

        Loading ->
            withLoader (div [] [])

        Success posts ->
            RemoteData.map userHeader model.user
                |> RemoteData.withDefault authHeader
                |> flip layout (landingBody posts)

        Failure err ->
            error err


readPost : String -> Model -> Html Msg
readPost id model =
    case model.posts of
        NotAsked ->
            div [] []

        Loading ->
            withLoader (div [] [])

        Success posts ->
            case List.head <| List.filter (\post -> post.id == id) posts of
                Just post ->
                    RemoteData.map userHeader model.user
                        |> RemoteData.withDefault authHeader
                        |> flip layout (readPostBody post)

                Nothing ->
                    error "404 Not Found"

        Failure err ->
            error err


createPost : Model -> Html Msg
createPost model =
    case model.user of
        NotAsked ->
            error "404 Not Found"

        Loading ->
            withLoader <| div [] []

        Success user ->
            layout (userHeader user) (createPostBody model.form)

        Failure err ->
            error err


login : Model -> Html Msg
login model =
    case RemoteData.append model.token model.user of
        NotAsked ->
            Components.login model.form

        Loading ->
            withLoader <| Components.login model.form

        Success _ ->
            landing model

        Failure err ->
            error err


signUp : Model -> Html Msg
signUp model =
    case model.account of
        NotAsked ->
            Components.signUp model.form

        Loading ->
            withLoader <| Components.signUp model.form

        Success a ->
            Components.signUp model.form

        Failure err ->
            error err


error : a -> Html msg
error err =
    Components.error err


view : Model -> Html Msg
view model =
    case model.route of
        HomeRoute ->
            landing model

        ReadPostRoute id ->
            readPost id model

        CreatePostRoute ->
            createPost model

        LoginRoute ->
            login model

        SignUpRoute ->
            signUp model

        ErrorRoute ->
            error "404 Not Found"

module Main exposing (..)

--https://ewendel.github.io/elm-workshop/
-- import Html.Events exposing (..)

import Api
import Components exposing (..)
import Date exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as JD exposing (Decoder, andThen, field, int, string)
import Json.Decode.Extra exposing (fromResult)
import Messages exposing (..)
import Models exposing (..)
import Navigation exposing (Location)
import Pages exposing (..)
import Persistence
import Platform.Cmd exposing (batch)
import RemoteData exposing (RemoteData(Failure, Loading, NotAsked, Success), WebData, isSuccess)
import Routes exposing (..)
import Task exposing (..)


-- import Time exposing (..)
-- import Data
-- main =
--     beginnerProgram
--         { model = init
--         , view = view
--         , update = update
--         }
-- main =
--     Html.program
--         { init = init "filter"
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }


main : Program (Maybe Token) Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = Pages.view
        , update = update
        , subscriptions = \model -> Persistence.get OnLoadToken
        }



-- MODEL


init : Maybe Token -> Location -> ( Model, Cmd Msg )
init token location =
    let
        model =
            { initialModel
                | token = Maybe.map RemoteData.succeed token |> Maybe.withDefault RemoteData.NotAsked
                , route = parseLocation location
            }
    in
    fetchPosts model
        |> andThen fetchUser
        |> Tuple.mapSecond batch


fetchUser : Model -> ( Model, List (Cmd Msg) )
fetchUser model =
    case model.token of
        Success tok ->
            ( { model | user = RemoteData.Loading }, [ Api.fetchUser tok ] )

        Failure err ->
            ( { model | user = RemoteData.Failure err }, [] )

        _ ->
            ( model, [] )


fetchPosts : Model -> ( Model, List (Cmd Msg) )
fetchPosts model =
    ( model, [ Api.fetchPosts ] )


andThen : (a -> ( b, List c )) -> ( a, List c ) -> ( b, List c )
andThen apply ( a, c ) =
    let
        ( b, d ) =
            apply a
    in
    ( b, c ++ d )


updateRoute : Route -> Model -> ( Model, List (Cmd Msg) )
updateRoute route model =
    ( model, [ Navigation.newUrl <| path route ] )


resetForm : Model -> ( Model, List (Cmd msg) )
resetForm model =
    case ( model.user, model.account ) of
        ( Success _, _ ) ->
            ( { model | form = initialForm }, [] )

        ( _, Success _ ) ->
            ( { model | form = initialForm }, [] )

        _ ->
            ( model, [] )


saveToken : Model -> ( Model, List (Cmd msg) )
saveToken model =
    ( model, [ Persistence.put <| RemoteData.toMaybe model.token ] )


removeToken : Model -> ( Model, List (Cmd msg) )
removeToken model =
    ( model, [ Persistence.put Nothing ] )


reroute : Model -> ( Model, List (Cmd msg) )
reroute model =
    case ( model.route, isSuccess model.user, isSuccess model.account ) of
        ( SignUpRoute, False, True ) ->
            ( { model | account = RemoteData.NotAsked }, [ Navigation.newUrl <| path LoginRoute ] )

        ( LoginRoute, True, _ ) ->
            ( model, [ Navigation.modifyUrl <| path HomeRoute ] )

        ( SignUpRoute, True, _ ) ->
            ( model, [ Navigation.modifyUrl <| path HomeRoute ] )

        ( CreatePostRoute, False, _ ) ->
            ( { model | route = ErrorRoute }, [ Cmd.none ] )

        _ ->
            ( model, [ Cmd.none ] )



-- UPDATE
-- | OnTime Time
-- type Msg2
--     = OnTime Time
-- getTime : Cmd Msg2
-- getTime =
--     Task.perform OnTime Time.now


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- MorePlease ->
        --     ( model, getArrangementer model.topic )
        -- NewGif (Ok arrangementResultat) ->
        --     ( { model
        --         | arrangementResultat = Just arrangementResultat
        --       }
        --     , Cmd.none
        --     )
        -- NewGif (Err httpError) ->
        --     ( { model
        --         | errorMessage = Just (createErrorMessage httpError)
        --       }
        --     , Cmd.none
        --     )
        -- RequestDate ->
        --     ( model, Task.perform ReceiveDate Date.now )
        -- ReceiveDate date ->
        --     let
        --         nextModel =
        --             { model | today = Just date }
        --     in
        --     ( nextModel, Cmd.none )
        -- LoggInn ->
        --     ( model, Cmd.none )
        OnLocationChange location ->
            ( { model | route = parseLocation location }, [] )
                |> andThen reroute
                |> Tuple.mapSecond batch

        UpdateRoute route ->
            updateRoute route model
                |> Tuple.mapSecond batch

        OnInput form ->
            ( { model | form = form }, Cmd.none )

        CreatePost ->
            ( model, RemoteData.map Api.authenticate model.token |> RemoteData.withDefault Cmd.none )

        Logout ->
            ( { model | user = RemoteData.NotAsked }, [] )
                |> andThen removeToken
                |> andThen (updateRoute HomeRoute)
                |> Tuple.mapSecond batch

        SignUp ->
            ( { model | account = RemoteData.Loading }, Api.fetchAccount model.form )

        Login ->
            ( { model | token = RemoteData.Loading }, Api.fetchToken model.form )

        OnFetchAccount account ->
            ( { model | account = account }, [] )
                |> andThen resetForm
                |> andThen reroute
                |> Tuple.mapSecond batch

        OnFetchToken token ->
            ( { model | token = token }, [] )
                |> andThen saveToken
                |> andThen fetchUser
                |> Tuple.mapSecond batch

        OnFetchUser user ->
            ( { model | user = user }, [] )
                |> andThen resetForm
                |> andThen reroute
                |> Tuple.mapSecond batch

        OnFetchPosts posts ->
            ( { model | posts = posts }, Cmd.none )

        OnCreatePost post ->
            resetForm model
                |> andThen fetchPosts
                |> andThen (updateRoute HomeRoute)
                |> Tuple.mapSecond batch

        OnFetchGraphcoolToken token ->
            ( model, RemoteData.map (Api.createPost model.form) token |> RemoteData.withDefault Cmd.none )

        OnLoadToken token ->
            ( { model | token = Maybe.map RemoteData.succeed token |> Maybe.withDefault RemoteData.NotAsked }, Cmd.none )


type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus (Http.Response String)
    | BadPayload String (Http.Response String)


createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "It appears you don't have an Internet connection right now."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload message response ->
            message



-- VIEW


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
            Pages.login model

        SignUpRoute ->
            Pages.signUp model

        ErrorRoute ->
            Pages.error "404 Not Found"



-- div
--     []
--     [ Html.header
--         [ class "header" ]
--         [ h1
--             [ class "header__title" ]
--             [ text "Finn møte" ]
--         , button
--             [ onClick LoggInn ]
--             [ text "Logg inn" ]
--         -- , button
--         --     [ id "butAdd"
--         --     , class "headerButton"
--         --     , attribute "aria-label" "Add"
--         --     ]
--         --     []
--         ]
--     , div
--         [ class "top" ]
--         [ div
--             []
--             [ h3
--                 []
--                 [ text "Arrangører" ]
--             , div
--                 [ class "arrangoerer" ]
--                 [ div
--                     [ class "arrangoerTemplate"
--                     ]
--                     [ input
--                         [ class "arrangoerChk"
--                         , type_ "checkbox"
--                         ]
--                         []
--                     , label
--                         [ class "arrangoerNavn" ]
--                         []
--                     ]
--                 ]
--             ]
--         , main_
--             [ class "main" ]
--             [ viewNicknamesOrError model
--             , div
--                 [ class "mainContainer" ]
--                 []
--             ]
--         ]
--     ]
-- viewNicknamesOrError : Model -> Html Msg
-- viewNicknamesOrError model =
--     case model.errorMessage of
--         Just message ->
--             viewError message
--         Nothing ->
--             viewArrangementer model.arrangementResultat
-- viewArrangementer : Maybe ArrangementResultat -> Html Msg
-- viewArrangementer arrangementResultat =
--     case arrangementResultat of
--         Nothing ->
--             div [] [ text "Ingen data" ]
--         Just arrangementResultat ->
--             div []
--                 [ div []
--                     (List.map viewArrangement arrangementResultat.arrangementer)
--                 ]
-- viewError : String -> Html Msg
-- viewError errorMessage =
--     let
--         errorHeading =
--             "Couldn't fetch arrangementer at this time."
--     in
--     div []
--         [ h3 [] [ text errorHeading ]
--         , text ("Error: " ++ errorMessage)
--         ]
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP
-- getArrangementer : String -> Cmd Msg
-- getArrangementer topic =
--     let
--         url =
--             "http://localhost:5000/api/arrangement"
--         -- ++ topic
--     in
--     Http.send NewGif (Http.get url arrangementResultatDecoder)
-- arrangementResultatDecoder : Decoder ArrangementResultat
-- arrangementResultatDecoder =
--     JD.map2 ArrangementResultat
--         (field "dagensDato" date)
--         (field "arrangementer" arrangementListDecoder)
-- arrangementListDecoder : Decoder (List Arrangement)
-- arrangementListDecoder =
--     JD.list arrangementDecoder
-- arrangementDecoder : Decoder Arrangement
-- arrangementDecoder =
--     JD.map3 Arrangement
--         (field "id" int)
--         (field "beskrivelse" string)
--         (field "tidspunkt" date)
-- date : Decoder Date
-- date =
--     string |> JD.andThen (Date.fromString >> fromResult)

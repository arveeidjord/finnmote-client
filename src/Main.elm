module Main exposing (..)
--https://ewendel.github.io/elm-workshop/
-- import Html.Events exposing (..)

import Date exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as JD exposing (Decoder, andThen, field, int, string)
import Json.Decode.Extra exposing (fromResult)
import Task exposing (..)


-- import Time exposing (..)
-- import Data
-- main =
--     beginnerProgram
--         { model = init
--         , view = view
--         , update = update
--         }


main =
    Html.program
        { init = init "filter"
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { topic : String
    , arrangementResultat : Maybe ArrangementResultat
    , errorMessage : Maybe String
    , today : Maybe Date
    }


type alias Arrangement =
    { id : Int
    , beskrivelse : String
    , tidspunkt : Date
    }


type alias ArrangementResultat =
    { dagensDato : Date
    , arrangementer : List Arrangement
    }


init : String -> ( Model, Cmd Msg )
init topic =
    Model topic Nothing Nothing Nothing
        -- , getArrangementer topic
        -- , Task.perform ReceiveDate Date.now
        ! [ Task.perform ReceiveDate Date.now, getArrangementer topic ]



-- UPDATE


type Msg
    = MorePlease
    | NewGif (Result Http.Error ArrangementResultat)
    | RequestDate
    | ReceiveDate Date
    | LoggInn



-- | OnTime Time
-- type Msg2
--     = OnTime Time
-- getTime : Cmd Msg2
-- getTime =
--     Task.perform OnTime Time.now


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( model, getArrangementer model.topic )

        NewGif (Ok arrangementResultat) ->
            ( { model
                | arrangementResultat = Just arrangementResultat
              }
            , Cmd.none
            )

        NewGif (Err httpError) ->
            ( { model
                | errorMessage = Just (createErrorMessage httpError)
              }
            , Cmd.none
            )

        RequestDate ->
            ( model, Task.perform ReceiveDate Date.now )

        ReceiveDate date ->
            let
                nextModel =
                    { model | today = Just date }
            in
            ( nextModel, Cmd.none )

        LoggInn ->
            (model, Cmd.none)


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
    div
        []
        [ Html.header
            [ class "header" ]
            [ h1
                [ class "header__title" ]
                [ text "Finn møte" ]
            , button
                [ onClick LoggInn ]
                [ text "Logg inn" ]

            -- , button
            --     [ id "butAdd"
            --     , class "headerButton"
            --     , attribute "aria-label" "Add"
            --     ]
            --     []
            ]
        , div
            [ class "top" ]
            [ div
                []
                [ h3
                    []
                    [ text "Arrangører" ]
                , div
                    [ class "arrangoerer" ]
                    [ div
                        [ class "arrangoerTemplate"
                        ]
                        [ input
                            [ class "arrangoerChk"
                            , type_ "checkbox"
                            ]
                            []
                        , label
                            [ class "arrangoerNavn" ]
                            []
                        ]
                    ]
                ]
            , main_
                [ class "main" ]
                [ viewNicknamesOrError model
                , div
                    [ class "mainContainer" ]
                    []
                ]
            ]
        ]


viewNicknamesOrError : Model -> Html Msg
viewNicknamesOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            viewArrangementer model.arrangementResultat


viewArrangementer : Maybe ArrangementResultat -> Html Msg
viewArrangementer arrangementResultat =
    case arrangementResultat of
        Nothing ->
            div [] [ text "Ingen data" ]

        Just arrangementResultat ->
            div []
                [ div []
                    (List.map viewArrangement arrangementResultat.arrangementer)
                ]


viewTidspunkt : Date -> Html Msg
viewTidspunkt tidspunkt =
    div
        [ class "dato"
        ]
        [ h4
            [ class "arrangementDato" ]
            [ text (formaterTidspunkt tidspunkt) ]
        ]


formaterTidspunkt : Date -> String
formaterTidspunkt tidspunkt =
    -- if Date.day tidspunkt == Date.day getTime then
    --     "I dag"
    -- else
    toString (Date.dayOfWeek tidspunkt) ++ ", " ++ toString (Date.day tidspunkt) ++ " " ++ toString (Date.month tidspunkt)


viewArrangement : Arrangement -> Html Msg
viewArrangement arrangement =
    div []
        [ viewTidspunkt arrangement.tidspunkt
        , div
            [ class "card"
            ]
            [ div
                [ class "arrangementHeader" ]
                [ div
                    []
                    [ a
                        [ href "arrangoer.html"
                        , class "arrangementArrangoer"
                        ]
                        [ text "Arrangør" ]
                    , div
                        [ class "arrangementTekst midFont" ]
                        [ text arrangement.beskrivelse ]
                    , div
                        [ class "arrangementTaler" ]
                        []
                    ]
                , div
                    [ class "arrangementKl storFont" ]
                    []
                ]
            ]
        ]


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch arrangementer at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getArrangementer : String -> Cmd Msg
getArrangementer topic =
    let
        url =
            "http://localhost:5000/api/arrangement"

        -- ++ topic
    in
    Http.send NewGif (Http.get url arrangementResultatDecoder)


arrangementResultatDecoder : Decoder ArrangementResultat
arrangementResultatDecoder =
    JD.map2 ArrangementResultat
        (field "dagensDato" date)
        (field "arrangementer" arrangementListDecoder)


arrangementListDecoder : Decoder (List Arrangement)
arrangementListDecoder =
    JD.list arrangementDecoder


arrangementDecoder : Decoder Arrangement
arrangementDecoder =
    JD.map3 Arrangement
        (field "id" int)
        (field "beskrivelse" string)
        (field "tidspunkt" date)


date : Decoder Date
date =
    string |> JD.andThen (Date.fromString >> fromResult)

module Decoders exposing (..)

import Date
import Json.Decode as Decoder
import Json.Decode.Extra exposing (fromResult)
import Json.Decode.Pipeline as Pipeline
import Models exposing (Arrangement, Token, User)


decodeToken : Decoder.Decoder Token
decodeToken =
    Pipeline.decode Token
        |> Pipeline.required "token" Decoder.string
        |> Pipeline.required "userId" Decoder.int



-- |> Pipeline.required "id_token" Decoder.string
-- |> Pipeline.required "token_type" Decoder.string
-- |> Pipeline.required "expires_in" Decoder.int


decodeUser : Decoder.Decoder User
decodeUser =
    Pipeline.decode User
        |> Pipeline.required "brukernavn" Decoder.string


decodePosts : Decoder.Decoder (List Arrangement)
decodePosts =
    Decoder.list decodePost
        |> Decoder.field "arrangementer"


decodePost : Decoder.Decoder Arrangement
decodePost =
    Pipeline.decode Arrangement
        |> Pipeline.required "id" Decoder.int
        |> Pipeline.required "beskrivelse" Decoder.string
        |> Pipeline.required "arrangoerNavn" Decoder.string
        |> Pipeline.required "tidspunkt" date


date : Decoder.Decoder Date.Date
date =
    Decoder.string |> Decoder.andThen (Date.fromString >> fromResult)



-- intToString : Decoder.Decoder String
-- intToString =
--     Decoder.int |> Decoder.andThen (toString >> fromResult)
-- intToString2 : Int -> String
-- intToString2 tall =
--     toString tall


decodeGraphcoolToken : Decoder.Decoder String
decodeGraphcoolToken =
    Decoder.string
        |> Decoder.field "token"
        |> Decoder.field "authenticate"
        |> Decoder.field "data"

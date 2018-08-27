module Models exposing (..)

import Date exposing (..)
import DatePicker exposing (defaultSettings)
import RemoteData exposing (RemoteData(NotAsked), WebData)
import Routes exposing (..)


type alias Arrangement =
    { id : Int
    , beskrivelse : String
    , arrangoer : String
    , tidspunkt : Date
    }


type alias Arrangoer =
    { id : Int
    , navn : String
    , valgt : Bool
    }


type alias Model =
    { posts : WebData (List Arrangement)
    , arrangoerer : WebData (List Arrangoer)
    , form : Form
    , route : Route
    , user : WebData User
    , token : WebData Token
    , account : WebData ()
    }


type alias Token =
    { accessToken : String
    , userId : Int

    -- , idToken : String
    -- , tokenType : String
    -- , expiresIn : Int
    }


type alias ArrangementResultat =
    { dagensDato : Date
    , arrangementer : List Arrangement
    }


type alias Form =
    { navn : String
    , email : String
    , password : String
    , passwordAgain : String
    , postTidspunkt : String
    , postBody : String
    , datePicker : DatePicker.DatePicker
    , date : Maybe Date
    }


type alias User =
    { email : String
    }


initialModel : DatePicker.DatePicker -> Model
initialModel datePicker =
    { posts = NotAsked
    , arrangoerer = NotAsked
    , form = initialForm datePicker
    , route = HomeRoute
    , user = NotAsked
    , token = NotAsked
    , account = NotAsked
    }


initialForm : DatePicker.DatePicker -> Form
initialForm datePicker =
    { navn = "Ola Normann"
    , email = "admin@mail.com"
    , password = "admin"
    , passwordAgain = "admin"
    , postTidspunkt = ""
    , postBody = ""
    , datePicker = datePicker
    , date = Nothing
    }

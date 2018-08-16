module Models exposing (..)

import Date exposing (..)
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
    }


type alias Model =
    { posts : WebData (List Arrangement)
    ,  arrangoerer : WebData (List Arrangoer)
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
    , postTitle : String
    , postBody : String
    }


type alias User =
    { email : String
    }


initialModel : Model
initialModel =
    { posts = NotAsked
    , arrangoerer = NotAsked
    , form = initialForm
    , route = HomeRoute
    , user = NotAsked
    , token = NotAsked
    , account = NotAsked
    }


initialForm : Form
initialForm =
    { navn = "Ola Normann", email = "admin@mail.com", password = "admin", passwordAgain = "admin", postTitle = "", postBody = "" }

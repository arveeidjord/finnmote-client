module Models exposing (..)

import Date exposing (..)
import RemoteData exposing (RemoteData(NotAsked), WebData)
import Routes exposing (..)


type alias Post =
    { id : String
    , title : String
    , body : String
    }


type alias Model =
    { posts : WebData (List Post)
    , form : Form
    , route : Route
    , user : WebData User
    , token : WebData Token
    , account : WebData ()
    }


type alias Token =
    { accessToken : String
    , idToken : String
    , tokenType : String
    , expiresIn : Int
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


type alias Form =
    { email : String
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
    , form = initialForm
    , route = HomeRoute
    , user = NotAsked
    , token = NotAsked
    , account = NotAsked
    }


initialForm : Form
initialForm =
    { email = "admin@mail.com", password = "admin", passwordAgain = "admin", postTitle = "", postBody = "" }

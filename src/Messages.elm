module Messages exposing (..)

import Date exposing (..)
import Http
import Models exposing (ArrangementResultat, Form, Post, Token, User)
import Navigation exposing (Location)
import RemoteData exposing (WebData)
import Routes exposing (Route)


type Msg
    = -- MorePlease
      -- | NewGif (Result Http.Error ArrangementResultat)
      -- | RequestDate
      -- | ReceiveDate Date
      -- | LoggInn
      OnLocationChange Location
    | UpdateRoute Route
    | OnInput Form
    | CreatePost
    | Login
    | Logout
    | SignUp
    | OnFetchAccount (WebData ())
    | OnFetchToken (WebData Token)
    | OnFetchUser (WebData User)
    | OnLoadToken (Maybe Token)
    | OnFetchPosts (WebData (List Post))
    | OnCreatePost (WebData Post)
    | OnFetchGraphcoolToken (WebData String)

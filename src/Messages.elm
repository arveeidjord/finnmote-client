module Messages exposing (..)

-- import Date exposing (..)
-- import Http

import Models exposing (Arrangement, ArrangementResultat, Form, Token, User, Arrangoer)
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
    | OnFetchPosts (WebData (List Arrangement))
    | OnFetchArrangoerer (WebData (List Arrangoer))
    | OnCreatePost (WebData Arrangement)
    -- | OnFetchGraphcoolToken (WebData String)
    | VelgArrangoer (Arrangoer)

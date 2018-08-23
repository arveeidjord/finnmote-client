module Components exposing (..)

import Date exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Messages exposing (..)
import Models exposing (..)
import Routes exposing (..)


layout : Html msg -> Html msg -> Html msg
layout header main =
    div []
        [ header
        , main
        ]


authHeader : Html msg
authHeader =
    header [ class "header" ]
        [ nav [ class "topnav" ]
            [ a [ href <| path HomeRoute, class "tittelBtn" ] [ i [ class "fas fa-bars" ] [] ]
            , a [ href <| path HomeRoute, class "tittelBtn" ] [ text "Finn møte" ]
            , div [ class "topnav-right" ]
                [ a [ href <| path LoginRoute, class "btn" ] [ text "Logg inn" ]
                , a [ href <| path SignUpRoute, class "btn" ] [ text "Registrer" ]
                ]
            ]
        ]



-- [ nav []
--     [ div []
--         [ a [ href <| path LoginRoute, class "btn" ] [ text "Logg inn" ]
--         , a [ href <| path SignUpRoute, class "btn" ] [ text "Registrer" ]
--         ]
--     ]
-- ]


userHeader : User -> Html Msg
userHeader user =
    header []
        [ nav [ class "topnav" ]
            [ a [ href <| path CreatePostRoute, class "btn" ] [ text "Nytt arrangement" ]
            , div [ class "topnav-right" ]
                [ span [] [ text user.email ]
                , a [ onClick Logout, class "btn" ] [ text "Logg ut" ]
                ]
            ]
        ]



-- viewArrangement : Arrangement -> Html Msg
-- viewArrangement arrangement =
--     div []
--         [ viewTidspunkt arrangement.tidspunkt
--         , div
--             [ class "card"
--             ]
--             [ div
--                 [ class "arrangementHeader" ]
--                 [ div
--                     []
--                     [ a
--                         [ href "arrangoer.html"
--                         , class "arrangementArrangoer"
--                         ]
--                         [ text "Arrangør" ]
--                     , div
--                         [ class "arrangementTekst midFont" ]
--                         [ text arrangement.beskrivelse ]
--                     , div
--                         [ class "arrangementTaler" ]
--                         []
--                     ]
--                 , div
--                     [ class "arrangementKl storFont" ]
--                     []
--                 ]
--             ]
--         ]


postCard : Arrangement -> Html Msg
postCard post =
    div []
        [ viewTidspunkt post.tidspunkt
        , div [ onClick <| UpdateRoute <| ReadPostRoute post.id, class "card small hoverable grey lighten-4" ]
            [ div [ class "card-content" ]
                [ span [ class "card-title medium" ]
                    [ text post.arrangoer ]
                , p [] [ text <| String.left 300 post.beskrivelse ]
                ]
            ]
        ]



-- myStyle : Attribute msg
-- myStyle =
--     style
--         [ ( "backgroundColor", "red" )
--         , ( "height", "90px" )
--         , ( "width", "200px" )
--         ]


viewArrangementer : List Arrangement -> List Arrangoer -> Html Msg
viewArrangementer arrangementer arrangoerer =
    div []
        [ sidebarArrangoerer arrangoerer
        , landingBody arrangementer
        ]


landingBody : List Arrangement -> Html Msg
landingBody posts =
    main_ [ class "container" ]
        [ List.map postCard posts
            |> div [ class "row" ]
        ]


sidebarArrangoerer : List Arrangoer -> Html Msg
sidebarArrangoerer arrangoerer =
    div [ class "sidenav" ]
        [ sidebarTittel "Arrangør"
        , div []
            (List.map sidebarChk arrangoerer)
        ]


sidebarChk : Arrangoer -> Html Msg
sidebarChk arrangoer =
    label [ class "checkboxContainer" ]
        [ input [ type_ "checkbox", onClick (VelgArrangoer arrangoer) ] []
        , span [ class "checkboxCheckmark" ] []
        , text arrangoer.navn
        ]



-- checkbox arrangoer.navn
-- checkbox : String -> Html msg
-- checkbox name =
--     label []
--         [ input [ type_ "checkbox" ] []
--         , text name
--         ]
-- checkbox : msg -> String -> Html msg
-- checkbox msg name =
--     label []
--         [ input [ type_ "checkbox", onClick msg ] []
--         , text name
--         ]


sidebarTittel : String -> Html msg
sidebarTittel tittel =
    div
        [ class "headerBox"
        ]
        [ h4
            []
            [ text "Arrangør" ]
        ]



-- <div class="sidenav">
--   <a href="#about">About</a>
--   <a href="#services">Services</a>
--   <a href="#clients">Clients</a>
--   <a href="#contact">Contact</a>
-- </div>


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


login : Form -> Html Msg
login form =
    authentication
        [ emailInput form
        , passwordInput form
        , a [ onClick Login, class "btn right" ] [ text "Login" ]
        ]


signUp : Form -> Html Msg
signUp form =
    authentication
        [ navnInput form
        , emailInput form
        , passwordInput form
        , passwordAgain form
        , a [ onClick SignUp, class "btn right" ] [ text "Sign Up" ]
        ]


withLoader : Html msg -> Html msg
withLoader view =
    div [ class "full-height" ] [ view, loading ]


loaderPart : String -> Html msg
loaderPart color =
    div [ class ("spinner-layer spinner-" ++ color) ]
        [ div [ class "circle-clipper left" ]
            [ div [ class "circle" ] []
            ]
        , div [ class "gap-patch" ]
            [ div [ class "circle" ] []
            ]
        , div [ class "circle-clipper right" ]
            [ div [ class "circle" ] []
            ]
        ]


loading : Html msg
loading =
    div [ class "loading-wrapper" ]
        [ div [ class "loader" ]
            [ div [ class "preloader-wrapper active" ] <|
                List.map
                    loaderPart
                    [ "blue", "red", "yellow", "green" ]
            ]
        ]


readPostBody : Arrangement -> Html msg
readPostBody post =
    main_ [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col l6 offset-l3" ]
                [ --     h1 [] [ text post.title ]
                  -- ,
                  --   List.repeat 5 post.beskrivelse |> List.map (\par -> p [] [ text par ]) |> div []
                  text post.beskrivelse
                ]
            ]
        ]


createPostBody : Form -> Html Msg
createPostBody form =
    main_ [ class "container " ]
        [ div [ class "row" ]
            [ Html.form [ class "col s12 m8 offset-m2" ]
                [ div [ class "input-field" ]
                    [ input
                        [ placeholder "Post Title"
                        , value form.postTitle
                        , type_ "text"
                        , onInput (\title -> OnInput { form | postTitle = title })
                        ]
                        []
                    ]
                , div [ class "input-field" ]
                    [ textarea
                        [ placeholder "Enter post here..."
                        , onInput (\body -> OnInput { form | postBody = body })
                        ]
                        [ text form.postBody ]
                    ]
                , a [ onClick CreatePost, class "btn right" ] [ text "Create" ]
                ]
            ]
        ]


error : a -> Html msg
error a =
    main_ [ class "container" ] [ text <| toString a ]


authentication : List (Html Msg) -> Html Msg
authentication body =
    main_ [ class "container " ]
        [ div [ class "full-height row valign-wrapper" ]
            [ Html.form [ class "col s12 m4 offset-m4" ]
                body
            ]
        ]


navnInput : Form -> Html Msg
navnInput form =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "Navn" ]
        , input
            [ placeholder "Navn"
            , type_ "text"
            , value form.navn
            , onInput (\navn -> OnInput { form | navn = navn })
            ]
            []
        ]


emailInput : Form -> Html Msg
emailInput form =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "email" ]
        , input
            [ placeholder "Email"
            , type_ "text"
            , value form.email
            , onInput (\email -> OnInput { form | email = email })
            ]
            []
        ]


passwordInput : Form -> Html Msg
passwordInput form =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input
            [ placeholder "Password"
            , value form.password
            , type_ "password"
            , onInput (\password -> OnInput { form | password = password })
            ]
            []
        ]


passwordAgain : Form -> Html Msg
passwordAgain form =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input
            [ placeholder "Password Again"
            , value form.passwordAgain
            , type_ "password"
            , onInput (\again -> OnInput { form | passwordAgain = again })
            ]
            []
        ]

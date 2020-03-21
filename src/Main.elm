module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { name : String
    , loggedin : Bool
    }


init : Model
init =
    Model "" False



-- UPDATE


type Msg
    = Login
    | Logout
    | Name String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Login ->
            { model | loggedin = True }

        Logout ->
            { model | loggedin = False }

        Name name ->
            { model | name = name }



-- VIEW


view : Model -> Html Msg
view model =
    if model.loggedin then
        viewHello model.name

    else
        viewEnter model


viewHello : String -> Html Msg
viewHello name =
    div []
        [ div [] [ text ("Hello " ++ name ++ "!") ]
        , div [] [ button [ onClick Logout ] [ text "Logout" ] ]
        ]


viewEnter : Model -> Html Msg
viewEnter model =
    div []
        [ input [ type_ "text", placeholder "username", value model.name, onInput Name ] []
        , button [ onClick Login ] [ text "Login" ]
        ]

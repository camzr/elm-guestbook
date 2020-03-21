module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)



-- import Http
-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { name : String
    , loggedin : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" False, Cmd.none )



-- UPDATE


type Msg
    = Login
    | Logout
    | Name String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( { model | loggedin = True }, Cmd.none )

        Logout ->
            ( { model | loggedin = False }, Cmd.none )

        Name name ->
            ( { model | name = name }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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

module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, string)



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


type Comments
    = Failure
    | Loading
    | Success String


type Status
    = LoggedIn
    | LoggedOut


type alias Model =
    { user : Maybe String
    , status : Status
    , comments : Comments
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing LoggedOut Loading
    , Http.get
        { url = "http://localhost:5000/simple"
        , expect = Http.expectJson GotComments commentDecoder
        }
    )


commentDecoder : Decoder String
commentDecoder =
    field "comment" string



-- UPDATE


type Msg
    = Login
    | Logout
    | Name String
    | GotComments (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( { model | status = LoggedIn }, Cmd.none )

        Logout ->
            ( { model | status = LoggedOut, user = Nothing }, Cmd.none )

        Name name ->
            ( { model | user = Just name }, Cmd.none )

        GotComments result ->
            case result of
                Ok commentText ->
                    ( { model | comments = Success commentText }, Cmd.none )

                Err _ ->
                    ( { model | comments = Failure }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    if model.status == LoggedIn then
        viewHello model

    else
        viewEnter


viewComments : Comments -> Html Msg
viewComments maybecomments =
    case maybecomments of
        Failure ->
            div [] [ text "Failed to load comments" ]

        Loading ->
            div [] [ text "Loading ..." ]

        Success comments ->
            div [] [ text comments ]


viewGreeting : Maybe String -> Html msg
viewGreeting user =
    case user of
        Nothing ->
            div [] [ text "Hello stranger!" ]

        Just name ->
            div [] [ text ("Hello " ++ name ++ "!") ]


viewHello : Model -> Html Msg
viewHello model =
    div []
        [ viewGreeting model.user
        , viewComments model.comments
        , button [ onClick Logout ] [ text "Logout" ]
        ]


viewEnter : Html Msg
viewEnter =
    div []
        [ input [ type_ "text", placeholder "username", onInput Name ] []
        , button [ onClick Login ] [ text "Login" ]
        ]

module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map3, string)
import Json.Encode



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


type alias Comment =
    { user : String
    , time : String
    , comment : String
    }


type CommentsLoaded
    = Failure
    | Loading
    | Success (List Comment)


type Status
    = LoggedIn
    | LoggedOut


type alias Model =
    { user : Maybe String
    , status : Status
    , comments : CommentsLoaded
    , newcomment : Maybe String
    }


loadComments : Cmd Msg
loadComments =
    Http.get
        { url = "http://localhost:5000/"
        , expect = Http.expectJson GotComments commentDecoder
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing LoggedOut Loading Nothing
    , loadComments
    )


commentDecoder : Decoder (List Comment)
commentDecoder =
    Json.Decode.list
        (map3 Comment
            (field "user" string)
            (field "time" string)
            (field "comment" string)
        )



-- UPDATE


type Msg
    = Login
    | Logout
    | Name String
    | GotComments (Result Http.Error (List Comment))
    | SaveComment
    | NewComment String
    | CommentSaved (Result Http.Error ())


encodeNewComment : String -> String -> Json.Encode.Value
encodeNewComment user comment =
    Json.Encode.object
        [ ( "user", Json.Encode.string user )
        , ( "comment", Json.Encode.string comment )
        ]


postNewComment : Json.Encode.Value -> Cmd Msg
postNewComment jsonbody =
    Http.post
        { url = "http://localhost:5000/"
        , body = Http.jsonBody jsonbody
        , expect = Http.expectWhatever CommentSaved
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( { model | status = LoggedIn }, loadComments )

        Logout ->
            ( { model | status = LoggedOut, user = Nothing }, Cmd.none )

        Name name ->
            ( { model | user = Just name }, Cmd.none )

        GotComments result ->
            case result of
                Ok comments ->
                    ( { model | comments = Success comments }, Cmd.none )

                Err _ ->
                    ( { model | comments = Failure }, Cmd.none )

        SaveComment ->
            case model.newcomment of
                Nothing ->
                    ( model, Cmd.none )

                Just newcomment ->
                    case model.user of
                        Nothing ->
                            ( { model | newcomment = Nothing }, postNewComment (encodeNewComment "Anonymous" newcomment) )

                        Just user ->
                            ( { model | newcomment = Nothing }, postNewComment (encodeNewComment user newcomment) )

        NewComment newcomment ->
            ( { model | newcomment = Just newcomment }, Cmd.none )

        CommentSaved _ ->
            ( model, loadComments )



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


viewSingleComment : Comment -> Html msg
viewSingleComment entry =
    li []
        [ text ("On " ++ entry.time ++ " " ++ entry.user ++ " wrote: ")
        , br [] []
        , text entry.comment
        , br [] []
        , br [] []
        ]


viewComments : CommentsLoaded -> Html Msg
viewComments commentsloaded =
    case commentsloaded of
        Failure ->
            div [] [ text "Failed to load comments" ]

        Loading ->
            div [] [ text "Loading ..." ]

        Success commentslist ->
            div []
                [ ul [] (List.map viewSingleComment commentslist)
                ]


viewGreeting : Maybe String -> Html msg
viewGreeting user =
    case user of
        Nothing ->
            h1 [] [ text "Hello stranger!", hr [] [] ]

        Just name ->
            h1 [] [ text ("Hello " ++ name ++ "!"), hr [] [] ]


viewHello : Model -> Html Msg
viewHello model =
    div []
        [ viewGreeting model.user
        , viewComments model.comments
        , input [ type_ "text", placeholder "leave comment", value (Maybe.withDefault "" model.newcomment), onInput NewComment ] []
        , button [ onClick SaveComment ] [ text "Save" ]
        , hr [] []
        , button [ onClick Logout ] [ text "Logout" ]
        ]


viewEnter : Html Msg
viewEnter =
    div []
        [ input [ type_ "text", placeholder "username", onInput Name ] []
        , button [ onClick Login ] [ text "Login" ]
        ]

module Main exposing (..)

import Browser
import Element exposing (layout)
import Element.Border
import Element.Events
import Element.Font
import Element.Input
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
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    if model.status == LoggedIn then
        viewHello model

    else
        viewEnter


viewSingleComment : Comment -> Element.Element msg
viewSingleComment entry =
    Element.column [ Element.spacing 2 ]
        [ Element.row [ Element.spacing 15 ] [ Element.el [ Element.Font.bold ] (Element.text entry.user), Element.el [] (Element.text entry.time) ]
        , Element.paragraph [] [ Element.text entry.comment ]
        ]


viewComments : CommentsLoaded -> Element.Element Msg
viewComments commentsloaded =
    case commentsloaded of
        Failure ->
            Element.el [] (Element.text "Failed to load comments")

        Loading ->
            Element.el [] (Element.text "Loading ...")

        Success commentslist ->
            Element.column [ Element.spacing 10 ]
                (List.map
                    viewSingleComment
                    commentslist
                )


viewGreeting : Maybe String -> Element.Element Msg
viewGreeting user =
    Element.el [ Element.Font.size 36 ]
        (Element.text
            ("Hello "
                ++ Maybe.withDefault "stranger" user
                ++ "!"
            )
        )


viewHello : Model -> Html Msg
viewHello model =
    Element.layout
        [ Element.Font.family
            [ Element.Font.typeface "Courier New"
            ]
        ]
        (Element.column
            [ Element.padding 20
            , Element.width Element.fill
            ]
            [ Element.Input.button
                [ Element.Border.rounded 3
                , Element.Border.color (Element.rgb255 200 200 200)
                , Element.Border.width 1
                , Element.width (Element.fill |> Element.maximum 150)
                ]
                { onPress = Just Logout
                , label =
                    Element.el [ Element.centerX, Element.padding 12 ] (Element.text "logout")
                }
            , Element.column
                [ Element.centerX
                , Element.spacing 20
                , Element.width (Element.fill |> Element.maximum 500)
                ]
                [ viewGreeting model.user
                , viewComments model.comments
                , viewNewComment model.newcomment
                ]
            ]
        )


viewNewComment : Maybe String -> Element.Element Msg
viewNewComment newcomment =
    Element.column [ Element.spacing 5, Element.width Element.fill ]
        [ Element.text "Enter new comment"
        , Element.row [ Element.spacing 15, Element.width Element.fill ]
            [ Element.Input.text
                []
                { placeholder = Nothing
                , onChange = \s -> NewComment s
                , text = Maybe.withDefault "" newcomment
                , label =
                    Element.Input.labelHidden "new comment"
                }
            , Element.Input.button
                [ Element.Border.rounded 3
                , Element.Border.color (Element.rgb255 200 200 200)
                , Element.Border.width 1
                , Element.width (Element.px 100)
                , Element.alignRight
                ]
                { onPress = Just SaveComment
                , label =
                    Element.el [ Element.centerX, Element.padding 12 ] (Element.text "save")
                }
            ]
        ]


viewEnter : Html Msg
viewEnter =
    Element.layout
        [ Element.Font.family
            [ Element.Font.typeface "Courier New"
            ]
        ]
        (Element.column
            [ Element.centerX
            , Element.centerY
            , Element.padding 20
            ]
            [ Element.el [ Element.centerX ]
                (Element.text
                    "choose a user name"
                )
            , Element.el [ Element.padding 20 ] (Element.text "")
            , Element.row [ Element.spacing 20 ]
                [ Element.Input.text
                    [ Element.width (Element.fill |> Element.maximum 300)
                    ]
                    { placeholder = Nothing
                    , onChange = \s -> Name s
                    , text = ""
                    , label =
                        Element.Input.labelHidden "username"
                    }
                , Element.Input.button
                    [ Element.Border.rounded 3
                    , Element.Border.color (Element.rgb255 200 200 200)
                    , Element.Border.width 1
                    , Element.width (Element.fill |> Element.maximum 300)
                    ]
                    { onPress = Just Login
                    , label =
                        Element.el [ Element.centerX, Element.padding 12 ] (Element.text "enter")
                    }
                ]
            ]
        )

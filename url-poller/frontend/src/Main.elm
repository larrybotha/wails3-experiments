port module Main exposing (..)

import Browser
import Html exposing (Html, a, button, div, h1, img, input, text)
import Html.Attributes exposing (alt, class, src, type_, value)
import Html.Events exposing (onClick, onInput)



-- PORTS


port pollStartEmitter : { url : String, durationSeconds : Int } -> Cmd msg


port pollStartReceiver : (String -> msg) -> Sub msg


port pollStopEmitter : () -> Cmd msg


port pollStopReceiver : (String -> msg) -> Sub msg


port pollResultReceiver : (PollResult -> msg) -> Sub msg



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


type alias PollResult =
    { timestamp : String
    , statusCode : Int
    , success : Bool
    , error : Maybe String
    , bodyPreview : String
    }


type alias Model =
    { pollUrl : String
    , pollDuration : String
    , pollResults : List PollResult
    , pollingStatus : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { pollUrl = ""
      , pollDuration = ""
      , pollResults = []
      , pollingStatus = "Not polling"
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdatePollUrl String
    | UpdatePollDuration String
    | DoStartPolling
    | DoStopPolling
    | StartPollingResult String
    | StopPollingResult String
    | NewPollResult PollResult


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdatePollUrl url ->
            ( { model | pollUrl = url }, Cmd.none )

        UpdatePollDuration duration ->
            ( { model | pollDuration = duration }, Cmd.none )

        DoStartPolling ->
            case String.toInt model.pollDuration of
                Just duration ->
                    if duration > 0 && not (String.isEmpty model.pollUrl) then
                        ( { model | pollResults = [], pollingStatus = "Starting..." }
                        , pollStartEmitter { url = model.pollUrl, durationSeconds = duration }
                        )

                    else
                        ( { model | pollingStatus = "Please enter a valid URL and duration > 0" }, Cmd.none )

                Nothing ->
                    ( { model | pollingStatus = "Duration must be a number" }, Cmd.none )

        DoStopPolling ->
            ( { model | pollingStatus = "Stopping..." }, pollStopEmitter () )

        StartPollingResult result ->
            ( { model | pollingStatus = result }, Cmd.none )

        StopPollingResult result ->
            ( { model | pollingStatus = result }, Cmd.none )

        NewPollResult result ->
            ( { model | pollResults = model.pollResults ++ [ result ] }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ pollStartReceiver StartPollingResult
        , pollStopReceiver StopPollingResult
        , pollResultReceiver NewPollResult
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div []
            [ a [ Html.Attributes.attribute "data-wml-openURL" "https://wails.io" ]
                [ img [ src "/wails.png", class "logo", alt "Wails logo" ] []
                ]
            , a [ Html.Attributes.attribute "data-wml-openURL" "https://elm-lang.org" ]
                [ img [ src "https://elm-lang.org/images/elm-logo.svg", class "logo vanilla", alt "Elm logo" ] []
                ]
            ]
        , h1 [] [ text "Wails + Elm" ]
        , div [ class "card" ]
            [ h1 [] [ text "URL Poller" ]
            , div [ class "input-box" ]
                [ input
                    [ class "input"
                    , type_ "text"
                    , Html.Attributes.placeholder "Enter URL"
                    , value model.pollUrl
                    , onInput UpdatePollUrl
                    ]
                    []
                ]
            , div [ class "input-box" ]
                [ input
                    [ class "input"
                    , type_ "number"
                    , Html.Attributes.placeholder "Duration (seconds)"
                    , value model.pollDuration
                    , onInput UpdatePollDuration
                    ]
                    []
                ]
            , div [ class "input-box" ]
                [ button [ class "btn", onClick DoStartPolling ] [ text "Start Polling" ]
                , button [ class "btn", onClick DoStopPolling ] [ text "Stop Polling" ]
                ]
            , div [ class "result" ] [ text model.pollingStatus ]
            , viewPollResults model.pollResults
            ]
        ]


viewPollResults : List PollResult -> Html Msg
viewPollResults results =
    if List.isEmpty results then
        div [] []

    else
        div [ class "poll-results" ]
            [ h1 [] [ text "Poll Results" ]
            , div [] (List.map viewPollResult results)
            ]


viewPollResult : PollResult -> Html Msg
viewPollResult result =
    let
        statusClass =
            if result.success then
                "poll-result-success"

            else
                "poll-result-error"
    in
    div [ class ("poll-result " ++ statusClass) ]
        [ div [] [ text ("Time: " ++ result.timestamp) ]
        , case result.error of
            Just errorMsg ->
                div [] [ text ("Error: " ++ errorMsg) ]

            Nothing ->
                div [] [ text ("Status: " ++ String.fromInt result.statusCode) ]
        , if not (String.isEmpty result.bodyPreview) then
            div [] [ text ("Preview: " ++ result.bodyPreview) ]

          else
            div [] []
        ]

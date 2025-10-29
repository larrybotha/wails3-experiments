port module Main exposing (..)

import Browser
import Html exposing (Html, a, button, div, h1, img, input, p, text)
import Html.Attributes exposing (alt, autocomplete, class, id, src, type_, value)
import Html.Events exposing (onClick, onInput)



-- PORTS


port greet : String -> Cmd msg


port greetResult : (String -> msg) -> Sub msg


port timeEvent : (String -> msg) -> Sub msg



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
    , result : String
    , time : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { name = ""
      , result = "Please enter your name below 👇"
      , time = "Listening for Time event..."
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdateName String
    | DoGreet
    | GreetResult String
    | TimeUpdate String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateName newName ->
            ( { model | name = newName }, Cmd.none )

        DoGreet ->
            let
                nameToGreet =
                    if String.isEmpty model.name then
                        "anonymous"

                    else
                        model.name
            in
            ( model, greet nameToGreet )

        GreetResult result ->
            ( { model | result = result }, Cmd.none )

        TimeUpdate time ->
            ( { model | time = time }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ greetResult GreetResult
        , timeEvent TimeUpdate
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
            [ div [ class "result", id "result" ] [ text model.result ]
            , div [ class "input-box", id "input" ]
                [ input
                    [ class "input"
                    , id "name"
                    , type_ "text"
                    , autocomplete False
                    , value model.name
                    , onInput UpdateName
                    ]
                    []
                , button [ class "btn", onClick DoGreet ] [ text "Greet" ]
                ]
            ]
        , div [ class "footer" ]
            [ div [] [ p [] [ text "Click on the Wails logo to learn more" ] ]
            , div [] [ p [ id "time" ] [ text model.time ] ]
            ]
        ]

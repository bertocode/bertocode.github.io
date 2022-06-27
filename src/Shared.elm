port module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Navigation
import DataSource
import Html exposing (Html, a, div, nav, span, text)
import Html.Attributes exposing (class, classList, href, style, tabindex)
import Html.Events exposing (onClick)
import Json.Decode as D
import Pages.Flags exposing (Flags(..))
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


port toggleTheme : () -> Cmd msg


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg
    | ToggleTheme


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMobileMenu : Bool
    , lightTheme : Bool
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init navigationKey flags maybePagePath =
    ( { showMobileMenu = False
      , lightTheme = flagsDecoderAttribute flags "theme" D.bool False
      }
    , Cmd.none
    )


flagsDecoderAttribute : Flags -> String -> D.Decoder a -> a -> a
flagsDecoderAttribute flags attribute decoder defaultValue =
    case flags of
        PreRenderFlags ->
            defaultValue

        BrowserFlags bFlags ->
            case D.decodeValue (D.field attribute decoder) bFlags of
                Ok decodedValue ->
                    decodedValue

                Err _ ->
                    defaultValue


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Cmd.none )

        SharedMsg globalMsg ->
            ( model, Cmd.none )

        ToggleTheme ->
            ( { model | lightTheme = not model.lightTheme }, toggleTheme () )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


view :
    Data
    ->
        { path : Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    { body =
        Html.div
            []
        <|
            nav [ class "main-navbar" ]
                [ div [ style "font-size" "2.5rem" ] [ text "bertocode" ]
                , div [ class "main-navbar-right" ]
                    [ a [ onClick <| toMsg ToggleTheme, href "#", tabindex 0 ]
                        [ span [ class "material-symbols-rounded" ] <|
                            if model.lightTheme then
                                [ text "dark_mode" ]

                            else
                                [ text "light_mode" ]
                        ]
                    , a [] [ text "Home" ]
                    ]
                ]
                :: pageView.body
    , title = pageView.title
    }

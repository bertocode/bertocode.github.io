module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Navigation
import DataSource
import Html exposing (Html, a, div, nav, span, text)
import Html.Attributes exposing (class, classList, href, style, tabindex)
import Html.Events exposing (onClick)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


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
    | ToggleDarkMode


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMobileMenu : Bool
    , darkTheme : Bool
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
      , darkTheme = True
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Cmd.none )

        SharedMsg globalMsg ->
            ( model, Cmd.none )

        ToggleDarkMode ->
            ( { model | darkTheme = not model.darkTheme }, Cmd.none )


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
            [ classList [ ( "dark-theme", model.darkTheme ), ( "light-theme", not model.darkTheme ) ]
            ]
        <|
            nav [ class "main-navbar" ]
                [ div [ style "font-size" "2.5rem" ] [ text "bertocode" ]
                , div [ class "main-navbar-right" ]
                    [ a [ onClick <| toMsg ToggleDarkMode, href "#", tabindex 0 ]
                        [ span [ class "material-symbols-rounded" ] <|
                            if model.darkTheme then
                                [ text "light_mode" ]

                            else
                                [ text "dark_mode" ]
                        ]
                    , a [] [ text "Home" ]
                    ]
                ]
                :: pageView.body
    , title = pageView.title
    }

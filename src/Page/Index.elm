module Page.Index exposing (Data, Model, Msg, page)

import Accessibility as Html exposing (a, div, nav, text)
import Accessibility.Landmark as Landmark
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html.Attributes exposing (class)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "bertocode.github.io"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Bertocode Website - Thoughts, resources and experiences of Berto as an engineer"
        , locale = Nothing
        , title = "Bertocode Website" -- metadata.title -- TODO
        }
        |> Seo.website


type alias Data =
    ()


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Welcome to Bertocode's elm-pages"
    , body =
        [ nav [ class "main-navbar" ]
            [ div [] [ text "Berto" ]
            , div []
                [ a [] [ text "Theme" ]
                , a [] [ text "Home" ]

                --, a [] [ text "About" ]
                --, a [] [ text "Contact" ]
                ]
            ]
        ]
    }

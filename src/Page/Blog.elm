module Page.Blog exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (div, text)
import Page exposing (Page, StaticPayload)
import Page.Index exposing (Data, Msg)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias RouteParams =
    {}


type alias Model =
    ()


type alias Msg =
    Never


data : DataSource Data
data =
    DataSource.succeed ()


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


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
        , description = "Bertocode Website - Thoughts, resources and experiences from Berto"
        , locale = Nothing
        , title = "Bertocode Website"
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
    { title = "Berto Website"
    , body =
        [ div [] [ text "blog" ] ]
    }

module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (b, div, h1, h2, h3, img, main_, text)
import Html.Attributes exposing (alt, class, src, style)
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
    { title = "Bertocode"
    , body =
        [ main_ []
            [ h1 [] [ text "I'm Berto" ]
            , h2 [ style "margin-top" "3rem", style "text-align" "center" ]
                [ text "Software engineer, love working with people, interested in functional languages and solving problems"
                ]
            , img
                [ style "display" "flex"
                , style "margin" "3rem auto"
                , style "border-radius" "50%"
                , style "max-width" "75%"
                , src "/photo-of-me.png"
                , alt "Photo from Berto in the top of the mountain Sněžka, in the border between Czech Republic and Poland"
                ]
                []
            , div [ style "text-align" "center", style "margin-top" "3rem" ]
                [ text "You can reach me at "
                , b [] [ text "bertocode@gmail.com" ]
                ]
            ]
        ]
    }

module Page.Blog.Slug_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob exposing (Glob)
import Head
import Head.Seo as Seo
import Html exposing (h1, main_, text)
import Markdown
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Route exposing (Route(..))
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { slug : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    blogPostFiles
        |> DataSource.map
            (List.map
                (\globData ->
                    { slug = globData |> String.replace "blog/" "" |> String.replace ".md" "" }
                )
            )


data : RouteParams -> DataSource Data
data routeParams =
    blogPost routeParams.slug


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = static.data.title
        }
        |> Seo.website


type alias Data =
    BlogPostMetadata


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.data.title ++ " - bertocode"
    , body =
        [ main_ []
            [ h1 []
                [ text static.data.title ]
            , Markdown.toHtml [] static.data.body
            ]
        ]
    }


blogPost : String -> DataSource BlogPostMetadata
blogPost slug =
    File.bodyWithFrontmatter blogPostDecoder
        ("blog/" ++ slug ++ ".md")


type alias BlogPostMetadata =
    { body : String
    , title : String
    , tags : List String
    }


blogPostDecoder : String -> Decoder BlogPostMetadata
blogPostDecoder body =
    Decode.map2 (BlogPostMetadata body)
        (Decode.field "title" Decode.string)
        (Decode.field "tags" (Decode.list Decode.string))


blogPostFiles : DataSource (List String)
blogPostFiles =
    Glob.succeed identity
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "blog/")
        |> Glob.match Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource

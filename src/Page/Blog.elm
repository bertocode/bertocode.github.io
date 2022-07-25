module Page.Blog exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Html exposing (a, div, main_, text, li, ul)
import Html.Attributes exposing (href)
import OptimizedDecoder as Decode exposing (Decoder)
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
    allMetadata


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
    List BlogPostMetadata


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Berto Website"
    , body =
        [ main_ [] [
            li [] <|
            List.map
                (\bPost ->
                    
                    ul [] [a [ href bPost.path ] 
                    [ text (bPost.title) ]]
                )
                static.data
                ]
        ]
    }


type alias BlogPostMetadata =
    { title : String
    , tags : List String
    , date : String
    , path : String
    }


blogPostDecoder : String -> Decoder BlogPostMetadata
blogPostDecoder dataTitle =
    Decode.map4 BlogPostMetadata
        (Decode.field "title" Decode.string)
        (Decode.field "tags" (Decode.list Decode.string))
        (Decode.field "date" Decode.string)
        (Decode.succeed dataTitle |> Decode.andThen (\fileUrl -> String.replace ".md" "" fileUrl |> Decode.succeed))


blogPostFiles : DataSource (List String)
blogPostFiles =
    Glob.succeed identity
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "blog/")
        |> Glob.match Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


allMetadata : DataSource (List BlogPostMetadata)
allMetadata =
    blogPostFiles
        |> DataSource.map
            (List.map
                (\element -> File.onlyFrontmatter
                    (blogPostDecoder element) element
                )
            )
        |> DataSource.resolve

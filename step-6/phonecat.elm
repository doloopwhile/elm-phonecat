import Color
import Graphics.Element (..)
import Graphics.Input as Input
import Graphics.Input.Field as Field
import Http
import Json.Decode as D
import Json.Decode ((:=))
import List
import Result (Result(Err, Ok))
import Signal
import String
import Text

type alias Phone =
  {
    age:Float
  , id:String
  , imageUrl:String
  , name:String
  , snippet:String
  }

phoneDecoder : D.Decoder Phone
phoneDecoder = D.object5 Phone
  ("age"      := D.float)
  ("id"       := D.string)
  ("imageUrl" := D.string)
  ("name"     := D.string)
  ("snippet"  := D.string)

phonesApi : Signal (Http.Response (Result String (List Phone)))
phonesApi =
  Signal.map
    (\r ->
      case r of
        Http.Success s -> Http.Success (D.decodeString (D.list phoneDecoder) s)
        Http.Failure code text -> Http.Failure code text
        Http.Waiting -> Http.Waiting
    )
    (Http.sendGet <| Signal.constant "phones/phones.json")

query : Signal.Channel Field.Content
query = Signal.channel Field.noContent

order : Signal.Channel (List Phone -> List Phone)
order = Signal.channel identity

orderOptions : List (String, (List Phone -> List Phone))
orderOptions = [
    ("Alphabetical", (List.sortBy .age))
  , ("Newest",       (List.sortBy .name))
  ]

main : Signal Element
main = Signal.map3 scene (Signal.subscribe query) (Signal.subscribe order) phonesApi

scene : Field.Content -> (List Phone -> List Phone) -> (Http.Response (Result String (List Phone))) -> Element
scene q sortPhones phonesResp =
  case phonesResp of
    Http.Waiting ->
      Text.plainText "waiting"
    Http.Failure code text ->
      Text.plainText ("failed with " ++ (toString code) ++ " " ++ text)
    Http.Success resultPhones ->
      case resultPhones of
        Err error ->
          Text.plainText error
        Ok phones ->
          elements q sortPhones phones

elements : Field.Content -> (List Phone -> List Phone) -> (List Phone) -> Element
elements q sortPhones phones =
  flow right [
    flow down [
      Text.plainText "Search:"
    , Field.field Field.defaultStyle (Signal.send query) "" q
    , Input.dropDown (Signal.send order) orderOptions
    ]
  , flow down <|
      List.map listItem <|
      List.reverse <|
      sortPhones <|
      List.filter (phoneContainsText q.string) phones
  ]

phoneContainsText : String -> Phone -> Bool
phoneContainsText s p =
  (String.contains s p.name) || (String.contains s p.snippet)

listItem : Phone -> Element
listItem p =
  flow down [
    Text.plainText " "
  , flow right [
      link ("#/phones/" ++ p.id) <| image 100 100 p.imageUrl
    , flow down [
        link ("#/phones/" ++ p.id) <| Text.leftAligned <| Text.bold <| Text.fromString p.name
      , Text.plainText p.snippet
      ]
    ]
  , Text.plainText " "
  ]

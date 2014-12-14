module Phonecat where

import Color
import Graphics.Element (..)
import Graphics.Input as Input
import Graphics.Input.Field as Field
import Http
import Json.Decode as D
import Json.Decode ((:=))
import List
import Maybe (Maybe(Just, Nothing))
import Maybe
import Result (Result(Err, Ok))
import Regex
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

type alias Location =
  {
    hash:String
  , host:String
  , hostname:String
  , href:String
  , pathname:String
  , port_:String
  , protocol:String
  , search:String
  }

port location : Signal Location

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
main =
  let
    maybePhoneScene = \l ->
      case Regex.find (Regex.AtMost 1) (Regex.regex "^#/phones/([^/]+)$") l.hash of
        [{submatches}] ->
          case submatches of
            [Just id] -> Just (phoneScene id)
            _ -> Nothing
        _ -> Nothing
  in
    Signal.map4
      (\l q sortPhones phonesResp ->
        Maybe.withDefault
          (indexScene q sortPhones phonesResp)
          (maybePhoneScene l)
      )
     location (Signal.subscribe query) (Signal.subscribe order) phonesApi


phoneScene : String -> Element
phoneScene id = Text.plainText <| "TBD: detail view for " ++ id

indexScene : Field.Content -> (List Phone -> List Phone) -> (Http.Response (Result String (List Phone))) -> Element
indexScene q sortPhones phonesResp =
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
          indexElements q sortPhones phones

indexElements : Field.Content -> (List Phone -> List Phone) -> (List Phone) -> Element
indexElements q sortPhones phones =
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

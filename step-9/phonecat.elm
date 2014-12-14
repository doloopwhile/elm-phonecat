module Phonecat where

import Color
import Dict
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
import Signal ((<~), (~), Signal)
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

type alias Camera = {features: List String, primary: String}
type alias Display = {screenResolution:String, screenSize:String, touchScreen:Bool}
type alias Hardware = {accelerometer:Bool, audioJack:String, cpu:String, fmRadio:Bool, physicalKeyboard:Bool, usb:String}

type alias PhoneData = {
    availability: List String
  , camera: Camera
  , description: String
  , display: Display
  , hardware: Hardware
  , id: String
  , images: List String
  , name: String

  -- Elm supports upto only Json.Decode.object8
  -- In this example, omit following fields

  -- , additionalFeatures: String
  -- , android: {os:String, ui:String}
  -- , battery: Dict.Dict String String
  -- , connectivity: {bluetooth:String, cell:String, gps: Bool, infrared: Bool, wifi:String}
  -- , sizeAndWeight: {dimensions:List String, weight:String}
  -- , storage: {flash:String, ram:String}
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
  (\r ->
    case r of
      Http.Success s -> Http.Success (D.decodeString (D.list phoneDecoder) s)
      Http.Failure code text -> Http.Failure code text
      Http.Waiting -> Http.Waiting
  ) <~ (Http.sendGet <| Signal.constant "phones/phones.json")

phoneDataDecoder : D.Decoder PhoneData
phoneDataDecoder =
  D.object8
    PhoneData
    ("availability":= (D.list D.string))
    ("camera":= (
      D.object2
        Camera
        ("features" := (D.list D.string))
        ("primary" := D.string)
    ))
    ("description":= D.string)
    ("display":= (
      D.object3
        Display
        ("screenResolution" := D.string)
        ("screenSize" := D.string)
        ("touchScreen" := D.bool)
    ))
    ("hardware":= (
      D.object6
        Hardware
        ("accelerometer":= D.bool)
        ("audioJack" := D.string)
        ("cpu" := D.string)
        ("fmRadio" := D.bool)
        ("physicalKeyboard" := D.bool)
        ("usb" := D.string)
    ))
    ("id":= D.string)
    ("images":= (D.list D.string))
    ("name":= D.string)

    -- Elm supports upto only Json.Decode.object8
    -- In this example, omit following fields

    -- ("additionalFeatures":= D.string)
    -- ("android":= (
    --   D.object2
    --     ("os" := D.string)
    --     ("ui" := D.string)
    -- ))
    -- ("battery":= (D.dict D.float))
    -- ("connectivity":= (
    --   D.object5
    --     ("bluetooth" := D.string)
    --     ("cell" := D.string)
    --     ("gps" := D.bool)
    --     ("infrared" := D.bool)
    --     ("wifi" := D.string)
    -- ))
    -- ("sizeAndWeight":= (
    --   D.object2
    --     ("dimensions" := D.list D.string)
    --     ("weight" := D.string)
    -- ))
    -- ("storage" := (
    --   D.object2
    --     ("flash" := D.string)
    --     ("ram" := D.string)
    -- ))

query : Signal.Channel Field.Content
query = Signal.channel Field.noContent

order : Signal.Channel (List Phone -> List Phone)
order = Signal.channel identity

orderOptions : List (String, (List Phone -> List Phone))
orderOptions = [
    ("Alphabetical", (List.sortBy .age))
  , ("Newest",       (List.sortBy .name))
  ]

type Route
  = PhoneRoute (Http.Response (Result String PhoneData))
  | IndexRoute (
      Field.Content
    , (List Phone -> List Phone)
    , (Http.Response (Result String (List Phone)))
    )

main : Signal Element
main =
  (\route ->
    case route of
      PhoneRoute phoneDataResp -> phoneScene phoneDataResp
      IndexRoute (q, sortPhones, phonesResp) -> indexScene q sortPhones phonesResp
  ) <~ route


phoneDataApi : Signal (Maybe String) -> Signal (Http.Response (Result String PhoneData))
phoneDataApi maybeIdSignal =
  let
    urlSignal = (Maybe.withDefault "" << Maybe.map (\id -> "phones/" ++ id ++ ".json")) <~ maybeIdSignal
  in
    (\r ->
      case r of
        Http.Success s -> Http.Success (D.decodeString phoneDataDecoder s)
        Http.Failure code text -> Http.Failure code text
        Http.Waiting -> Http.Waiting
    ) <~ (Http.sendGet urlSignal)


route : Signal Route
route =
  let
    getId = (\l -> case Regex.find (Regex.AtMost 1) (Regex.regex "^#/phones/([^/]+)$") l.hash of
      [{submatches}] ->
        case submatches of
          [Just id] -> Just id
          _ -> Nothing
      _ -> Nothing
    )
    maybeIdSignal = getId <~ location
  in
    (\mid q sortPhones phonesResp phoneDataResp ->
      case mid of
        Nothing -> IndexRoute (q, sortPhones, phonesResp)
        Just _  -> PhoneRoute phoneDataResp
    ) <~ maybeIdSignal
       ~ (Signal.subscribe query)
       ~ (Signal.subscribe order)
       ~ phonesApi
       ~ (phoneDataApi maybeIdSignal)


phoneScene : (Http.Response (Result String PhoneData))-> Element
phoneScene phoneDataResp =
  case phoneDataResp of
    Http.Waiting ->
      Text.plainText "waiting"
    Http.Failure code text ->
      Text.plainText ("failed with " ++ (toString code) ++ " " ++ text)
    Http.Success r ->
      case r of
        Err error ->
          Text.plainText error
        Ok phoneData ->
          phoneElement phoneData

checkmark : Bool -> Element
checkmark x =
  if x then Text.plainText "\x2713" else Text.plainText "\x2718"

phoneElement : PhoneData -> Element
phoneElement p =
  let
    h1 s = Text.leftAligned <| Text.bold <| (Text.height 36) <| Text.fromString s
    h2 s = Text.leftAligned <| Text.bold <| (Text.height 16.8) <| Text.fromString s
    h3 s = Text.leftAligned <| Text.bold <| (Text.height 14) <| Text.fromString s
  in
    flow down [
      flow right [
        image 400 400 (List.head p.images)
      , flow down [
          h1 p.name
        , Text.plainText p.description
        , Text.plainText " "
        , flow right <| List.map (image 100 100) p.images
        ]
      ]
    , spacer 40 40
    , flow left <| List.map (container 200 250 middle << container 180 230 topLeft) [
        flow down
          ([h2 "Availability and Networks"] ++
          List.map Text.plainText p.availability)
      , flow down ([
          h2 "Camera"
        , h3 "Primary"
        , Text.plainText p.camera.primary
        , h3 "Features"] ++
        List.map Text.plainText p.camera.features
      )
      , flow down [
          h2 "Display"
        , h3 "Screen size"
        , Text.plainText p.display.screenSize
        , h3 "Screen resolution"
        , Text.plainText p.display.screenResolution
        , h3 "Touch screen"
        , checkmark p.display.touchScreen
        ]
      , flow down [
          h2 "Hardware"
        , h3 "CPU"
        , Text.plainText p.hardware.cpu
        , h3 "USB"
        , Text.plainText p.hardware.usb
        , h3 "Audip / headphone jack"
        , Text.plainText p.hardware.audioJack
        , h3 "FM Radio"
        , checkmark p.hardware.fmRadio
        , h3 "Accelerometer"
        , checkmark p.hardware.accelerometer
        ]
      ]
    ]

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

import Graphics.Element (Element, flow, down, right)
import Graphics.Input.Field as Field
import Graphics.Input as Input
import List
import Signal
import String
import Text

type alias Phone = { name:String, snippet:String, age:Int }

phones : List Phone
phones = [
    { name = "Nexus S"
    , snippet = "Fast just got faster with Nexus S."
    , age = 1 }
  , { name = "Motorola XOOM™ with Wi-Fi"
    , snippet = "The Next, Next Generation tablet."
    , age = 2 }
  , { name = "MOTOROLA XOOM™",
      snippet = "The Next, Next Generation tablet.",
      age = 3 }
  ]

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
main = Signal.map2 scene (Signal.subscribe query) (Signal.subscribe order)

scene : Field.Content -> (List Phone -> List Phone)-> Element
scene q sortPhones =
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
    Text.leftAligned <| Text.bold <| Text.fromString p.name
  , Text.plainText p.snippet
  , Text.plainText " "
  ]

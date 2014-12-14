import Graphics.Element (Element, flow, down, right)
import Graphics.Input.Field as Field
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

main : Signal Element
main = Signal.map scene (Signal.subscribe query)

scene : Field.Content -> Element
scene q =
  flow right [
    flow down [
      Text.plainText "Search:"
    , Field.field Field.defaultStyle (Signal.send query) "" q
    ]
  , flow down <| List.map listItem <| List.filter (phoneContainsText q.string) phones
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

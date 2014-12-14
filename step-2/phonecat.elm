import Graphics.Element (Element, flow, down)
import List
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

main : Element
main = flow down <| List.map listItem phones

listItem : Phone -> Element
listItem p =
  flow down [
    Text.leftAligned <| Text.bold <| Text.fromString p.name
  , Text.plainText p.snippet
  , Text.plainText " "
  ]

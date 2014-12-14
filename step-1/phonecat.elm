import Graphics.Element (Element, flow, down)
import List
import Text

phones : List (String, String)
phones = [
    ("Nexus S", "Fast just got faster with Nexus S.")
  , ("Motorola XOOM™ with Wi-Fi", "The Next, Next Generation tablet.")
  ]

main : Element
main = flow down <| List.map listItem phones

listItem : (String, String) -> Element
listItem (name, desc) =
  flow down [
    Text.leftAligned <| Text.bold <| Text.fromString name
  , Text.plainText desc
  , Text.plainText " "
  ]

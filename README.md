# AngularJS tutorial in Elm
Implement [AngularJS tutorial app](https://code.angularjs.org/1.3.5/docs/tutorial) in [Elm](http://elm-lang.org/)
and prove (or disprove) that Elm is as powerful as AngularJS.

# How to Use
## Setup Elm
This program require Elm v0.14 (or higher compatible versions).
See: http://elm-lang.org/Install.elm

## Compile and serve a step
Goto step-n and run rake. Then visit "http://localhost:8000/phonecat.html"
```sh
$ cd step-0
$ rake
elm-make --yes phonecat.elm --output phonecat.html
Compiled 1 file
Successfully generated phonecat.html
[2014-12-15 00:52:35] INFO  WEBrick 1.3.1
[2014-12-15 00:52:35] INFO  ruby 2.1.4 (2014-10-27) [x86_64-linux]
[2014-12-15 00:52:35] INFO  WEBrick::HTTPServer#start: pid=20959 port=8000
```

# Steps

 * **[step-0](https://github.com/doloopwhile/elm-phonecat/tree/master/step-0)** Bootstrapping
 * **[step-1](https://github.com/doloopwhile/elm-phonecat/tree/master/step-1)** Construct element from a list
 * **[step-2](https://github.com/doloopwhile/elm-phonecat/tree/master/step-2)** Record and type alias rather than tuple
 * **[step-3](https://github.com/doloopwhile/elm-phonecat/tree/master/step-3)** Field and filtering a list
 * **[step-4](https://github.com/doloopwhile/elm-phonecat/tree/master/step-4)** Dropdown and sorting a list
 * **[step-5](https://github.com/doloopwhile/elm-phonecat/tree/master/step-5)** Http and Json.Decoder
 * **[step-6](https://github.com/doloopwhile/elm-phonecat/tree/master/step-6)** Images and Links
 * **[step-7](https://github.com/doloopwhile/elm-phonecat/tree/master/step-7)** Port and emulating route
 * **[step-8](https://github.com/doloopwhile/elm-phonecat/tree/master/step-8)** Implement sub pages
 * **[step-9](https://github.com/doloopwhile/elm-phonecat/tree/master/step-9)** Checkbox (ngFilter is large topic for AngularJS but trivial for Elm)
 * **[step-A](https://github.com/doloopwhile/elm-phonecat/tree/master/step-A)** Clickable

# Target Versions

Resource           | Version
---                | ---
AngularJS tutorial | [v1.3.5](https://code.angularjs.org/1.3.5/docs/tutorial)
Elm                | v0.14
Haskell Platform   | 2014.2.0.0

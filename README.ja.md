# ElmによるAngularJS tutorial
[AngularJS tutorial app](https://code.angularjs.org/1.3.5/docs/tutorial)
を[Elm](http://elm-lang.org/)で再実装しました。

ElmにはAngularJSと同等のポテンシャルがあることを証明（または反証）するのが目的です。

# 使い方
## Elmのインストール
このプログラムはElm v0.14（または互換性がある上位バージョン）向けに書かれています。

インストール方法は http://elm-lang.org/Install.elm をご覧ください。


## コンパイルとWEBサーバーの起動
step-nに移動し`rake`を実行してください。
そして、ブラウザで "http://localhost:8000/phonecat.html" を開いてください。
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

# ステップ

 * **[step-0](https://github.com/doloopwhile/elm-phonecat/tree/master/step-0)** はじまり
 * **[step-1](https://github.com/doloopwhile/elm-phonecat/tree/master/step-1)** `List`から`Element`を構築する
 * **[step-2](https://github.com/doloopwhile/elm-phonecat/tree/master/step-2)** タプルの代わりにRecordとtype aliasを使う
 * **[step-3](https://github.com/doloopwhile/elm-phonecat/tree/master/step-3)** `Field`と`List`のフィルタリング
 * **[step-4](https://github.com/doloopwhile/elm-phonecat/tree/master/step-4)** ドロップダウンリストと`List`のソート
 * **[step-5](https://github.com/doloopwhile/elm-phonecat/tree/master/step-5)** `Http`と`Json.Decoder`
 * **[step-6](https://github.com/doloopwhile/elm-phonecat/tree/master/step-6)** 画像とリンク
 * **[step-7](https://github.com/doloopwhile/elm-phonecat/tree/master/step-7)** Portsとルーティング
 * **[step-8](https://github.com/doloopwhile/elm-phonecat/tree/master/step-8)** サブページ
 * **[step-9](https://github.com/doloopwhile/elm-phonecat/tree/master/step-9)** チェックボックス
 * **[step-A](https://github.com/doloopwhile/elm-phonecat/tree/master/step-A)** `Element`のクリック

# 対応バージョン

リソース           | Version
---                | ---
AngularJS tutorial | [v1.3.5](https://code.angularjs.org/1.3.5/docs/tutorial)
Elm                | v0.14
Haskell Platform   | 2014.2.0.0

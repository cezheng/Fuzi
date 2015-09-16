# Fuzi (斧子)

[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Fuzi.svg)](https://cocoapods.org/pods/Fuzi)
[![License](https://img.shields.io/cocoapods/l/Fuzi.svg?style=flat&color=gray)](http://opensource.org/licenses/MIT)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Fuzi.svg?style=flat)](http://cocoadocs.org/docsets/Fuzi)
[![Twitter](https://img.shields.io/badge/twitter-@AdamoCheng-blue.svg?style=flat)](http://twitter.com/AdamoCheng)

**軽くて、素早くて、 Swift の XML/HTML パーサー。**

Fuzi は Mattt Thompson氏の [Ono](https://github.com/mattt/Ono)(斧) に参照し Swift 言語で実装した XML/HTML パーサーである。

> Fuzi は漢字の`斧子`の中国語発音で、 意味は[Ono](https://github.com/mattt/Ono)(斧)と同じ。Onoは、[Nokogiri](http://nokogiri.org)(鋸)を参照し、創ったもの。

[English](https://github.com/cezheng/Fuzi/blob/master/README.md)
[简体中文](https://github.com/cezheng/Fuzi/blob/master/README-zh.md)
## クイックルック
```swift
let xml = "..."
do {
  let document = try XMLDocument(string: xml)
  
  if let root = document.root {
    // Accessing all child nodes of root element
    for element in root.children {
      print("\(element.tag): \(element.attributes)")
    }
    
    // Getting child element by tag & accessing attributes
    if let length = root.firstChild(tag:"Length", inNamespace: "dc") {
      print(length["unit"])     // `unit` attribute
      print(length.attributes)  // all attributes
    }
  }
  
  // XPath & CSS queries
  for element in document.xpath("") {
    print("\(element.tag): \(element.attributes)")
  }
  
  if let firstLink = document.firstChild(css: "a, link") {
    print(firstLink["href"])
  }
} catch let error {
  print(error)
}
```

## 機能
### Onoから貰った機能
- `libxml2`での素早いXMLパース
- [XPath](http://en.wikipedia.org/wiki/XPath) と [CSS](http://en.wikipedia.org/wiki/Cascading_Style_Sheets) クエリ
- 自動的にデータを日付や数字に変換する
- XML ネイムスペース
- `String` や `NSData` や `[CChar]`からXMLDocumentをロードする
- 全面的なユニットテスト
- 100%ドキュメント

### Fuziの改善点
- Swift 言語のネーミングやコーディングルールに沿って、クラスやメソッドを再設計した
- 日付や数字変換のフォマットを指定できる
- いくつかのバグ修正
- より多くのCSSクエリ対応 (これから)
- より多くのHTML便利メソッド (これから)


## 環境

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7.0


## インストール
### CocoaPods
[Cocoapods](http://cocoapods.org/) で簡単に `Fuzi` をインストールできます。 下記のように`Podfile`を編集してください:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
	pod 'Fuzi', '~> 0.1.0'
end
```

そして、下記のコマンドを実行してください:

```bash
$ pod install
```
### Carthage
下記の行を `Cartfile` か `Cartfile.private` かに追加してください:

```
github "cezheng/Fuzi" ~> 0.1.0
```
そして、下記のコマンドを実行してください:

```
$ carthage update
```

### 手動
1. `Fuzi`フォルダの `*.swift` ファイルをプロジェクトに追加してください。
2. `libxml2`フォルダをプロジェクトのフォルダのどこか（ `/path/to/somewhere`）にコピペしてください。
3. Xcode プロジェクトの `Build Settings` で:
   1. `Swift Compiler - Search Paths`の`Import Paths`に`/path/to/somewhere/libxml2`を追加してください。
   2. `Search Paths`の`Header Search Paths`に`$(SDKROOT)/usr/include/libxml2`を追加してください。
   3. `Linking`の`Other Linker Flags`に`lxml2`を追加してください。

##用例
###XML
```swift
import Fuzi

let xml = "..."
do {
  // if encoding is omitted, it defaults to NSUTF8StringEncoding
  let doc = try XMLDocument(string: html, encoding: NSUTF8StringEncoding)
  if let root = document.root {
    print(root.tag)
    
    // define a prefix for a namespace
    document.definePrefix("atom", defaultNamespace: "http://www.w3.org/2005/Atom")
    
    // get first child element with given tag in namespace(optional)
    print(root.firstChild(tag: "title", inNamespace: "atom")
    
    // iterate through all children
    for element in root.children {
      print("\(index) \(element.tag): \(element.attributes)")
    }
  }
  // you can also use CSS selector against XMLDocument when you feels it makes sense
} catch let error as XMLError {
  switch error {
  case .NoError: print("wth this should not appear")
  case .ParserFailure, .InvalidData: print(error)
  case .LibXMLError(let code, let message):
    print("libxml error code: \(code), message: \(message)")
  }
}
```
###HTML
`HTMLDocument` は `XMLDocument` サブクラス。

```swift
import Fuzi

let html = "<html>...</html>"
do {
  // if encoding is omitted, it defaults to NSUTF8StringEncoding
  let doc = try HTMLDocument(string: html, encoding: NSUTF8StringEncoding)
  
  // CSS queries
  if let elementById = doc.css("#id") {
    print(elementById.stringValue)
  }
  for link in doc.css("a, link") {
      print(link.dump())
      print(link["href"]
  }
  
  // XPath queries
  if let title = doc.firstChild(xpath: "//head/title") {
    print(title.stringValue)
  }
  for paragraph in doc.xpath(".//body/descendant::p") {
    print(meta["class"])
  }
} catch let error {
  print(error)
}
```

###エラー処理なんて、どうでもいいの場合

```swift
import Fuzi

let xml = "..."

// Don't show me the errors, just don't crash
if let doc1 = try? XMLDocument(string: xml) {
  //...
}

let html = "<html>...</html>"

// I'm sure this won't crash
let doc2 = try! HTMLDocument(string: html)
//...
```

##Onoからの移行?
下記2つのサンプルコードを見たら、`Ono`と`Fuzi`の違いをわかる。

[Onoサンプル](https://github.com/mattt/Ono/blob/master/Example/main.m)

[Fuziサンプル](https://github.com/cezheng/Fuzi/blob/master/FuziDemo/FuziDemo/main.swift)

###子要素を取得
**Ono**

```objc
[doc firstChildWithTag:tag inNamespace:namespace];
[doc firstChildWithXPath:xpath];
[doc firstChildWithXPath:css];
for (ONOXMLElement *element in parent.children) {
  //...
}
[doc childrenWithTag:tag inNamespace:namespace];
```
**Fuzi**

```swift
doc.firstChild(tag: tag, inNamespace: namespace)
doc.firstChild(xpath: xpath)
doc.firstChild(css: css)
for element in parent.children {
  //...
}
doc.children(tag: tag, inNamespace:namespace)
```
###クエリ結果を読み込む
**Ono**

Objective-Cの`NSFastEnumeration`。

```objc
// simply iterating through the results
// mark `__unused` to unused params `idx` and `stop`
[doc enumerateElementsWithXPath:xpath usingBlock:^(ONOXMLElement *element, __unused NSUInteger idx, __unused BOOL *stop) {
  NSLog(@"%@", element);
}];

// stop the iteration at second element
[doc enumerateElementsWithXPath:XPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
  *stop = (idx == 1);
}];

// getting element by index 
ONOXMLDocument *nthElement = [(NSEnumerator*)[doc CSS:css] allObjects][n];

// total element count
NSUInteger count = [(NSEnumerator*)[document XPath:xpath] allObjects].count;
```

**Fuzi**

Swift の `SequenceType` と `Indexable`。

```swift
// simply iterating through the results
// no need to write the unused `idx` or `stop` params
for element in doc.xpath(xpath) {
  print(element)
}

// stop the iteration at second element
for (index, element) in doc.xpath(xpath).enumerate() {
  if idx == 1 {
    break
  }
}

// getting element by index 
if let nthElement = doc.css(css)[n] {
  //...
}

// total element count
let count = doc.xpath(xpath).count
```

## ライセンス

`Fuzi` のオープンソースライセンスは MIT です。 詳しくはこちら [LICENSE](https://github.com/cezheng/Fuzi/blob/master/LICENSE) 。

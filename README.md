# Fuzi (斧子)

[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Fuzi.svg)](https://cocoapods.org/pods/Fuzi)
[![License](https://img.shields.io/cocoapods/l/Fuzi.svg?style=flat&color=gray)](http://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/cocoapods/p/Fuzi.svg?style=flat)](http://cocoadocs.org/docsets/Fuzi)
[![Twitter](https://img.shields.io/badge/twitter-@AdamoCheng-blue.svg?style=flat)](http://twitter.com/AdamoCheng)

**A fast & lightweight XML/HTML parser in Swift that makes your life easier.**

Fuzi is based on a Swift port of Mattt Thompson's [Ono](https://github.com/mattt/Ono)(斧), with moderate class & interface redesign following standard Swift conventions, along with several bug fixes.

> Fuzi(斧子) means "axe", in homage to [Ono](https://github.com/mattt/Ono)(斧), which in turn is inspired by [Nokogiri](http://nokogiri.org) (鋸), which means "saw".

[简体中文](https://github.com/cezheng/Fuzi/blob/master/README-zh.md)
[日本語](https://github.com/cezheng/Fuzi/blob/master/README-ja.md)
## A Quick Look
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

## Features
### Inherited from Ono
- Extremely performant document parsing and traversal, powered by `libxml2`
- Support for both [XPath](http://en.wikipedia.org/wiki/XPath) and [CSS](http://en.wikipedia.org/wiki/Cascading_Style_Sheets) queries
- Automatic conversion of date and number values
- Correct, common-sense handling of XML namespaces for elements and attributes
- Ability to load HTML and XML documents from either `String` or `NSData` or `[CChar]`
- Comprehensive test suite
- Full documentation

### Improved in Fuzi
- Simple, modern API following standard Swift conventions, no more return types like `AnyObject!` that cause unnecessary type casts
- Customizable date and number formatters
- Some bugs fixes
- Support for more CSS selectors (yet to come)
- More convinience methods for HTML Documents (yet to come)


## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7.0


## Installation
### CocoaPods (Not ready yet! Use carthage)
You can use [Cocoapods](http://cocoapods.org/) to install `Fuzi` by adding it to your to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
	pod 'Fuzi', '~> 0.1.0'
end
```

Then, run the following command:

```bash
$ pod install
```
### Carthage
Adding the following line to your `Cartfile` or `Cartfile.private`:

```
github "cezheng/Fuzi"
```
Then, run the following command:

```
$ carthage update
```
##Usage
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
} catch let error {
}
```
###HTML
`HTMLDocument` is a subclass of `XMLDocument`.

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
}
```

##Migrating From Ono?
Looking at example program is the swiftest way to know the difference. The following 2 examples do exactly the same thing.

[Ono Example](https://github.com/mattt/Ono/blob/master/Example/main.m)

[Fuzi Example](https://github.com/cezheng/Fuzi/blob/master/FuziDemo/main.swift)

## License

`Fuzi` is released under the MIT license. See [LICENSE](https://github.com/cezheng/PySwiftyRegex/blob/master/LICENSE) for details.
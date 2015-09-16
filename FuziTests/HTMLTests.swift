// HTMLTests.swift
// Copyright (c) 2015 Ce Zheng
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
import Fuzi

class HTMLTests: XCTestCase {
  var document: XMLDocument!
  override func setUp() {
    super.setUp()
    let filePath = NSBundle(forClass: HTMLTests.self).pathForResource("web", ofType: "html")!
    do {
      document = try HTMLDocument(data: NSData(contentsOfFile: filePath)!)
    } catch {
      XCTAssertFalse(true, "Error should not be thrown")
    }
  }
  
  func testRoot() {
    XCTAssertEqual(document.root!.tag, "html", "html not root element")
  }
  
  func testRootChildren() {
    let children = document.root?.children
    XCTAssertNotNil(children)
    XCTAssertEqual(children?.count, 2, "root element should have exactly two children")
    XCTAssertEqual(children?.first?.tag, "head", "head not first child of html")
    XCTAssertEqual(children?.last?.tag, "body", "body not last child of html")
  }
  
  func testTitleXPath() {
    var idx = 0
    for element in document.xpath("//head/title") {
      XCTAssertEqual(idx, 0, "more than one element found")
      XCTAssertEqual(element.stringValue, "mattt/Ono", "title mismatch")
      idx++
    }
    XCTAssertEqual(idx, 1, "should be exactly 1 element")
  }
  
  func testTitleCSS() {
    var idx = 0
    for element in document.css("head title") {
      XCTAssertEqual(idx, 0, "more than one element found")
      XCTAssertEqual(element.stringValue, "mattt/Ono", "title mismatch")
      idx++
    }
    XCTAssertEqual(idx, 1, "should be exactly 1 element")
  }
  
  func testIDCSS() {
    var idx = 0
    for element in document.css("#account_settings") {
      XCTAssertEqual(idx, 0, "more than one element found")
      XCTAssertEqual(element["href"], "/settings/profile", "href mismatch")
      idx++
    }
    XCTAssertEqual(idx, 1, "should be exactly 1 element")
  }
  
  func testThrowError() {
    do {
      document = try HTMLDocument(cChars: [CChar]())
      XCTAssertFalse(true, "error should have been thrown")
    } catch XMLError.ParserFailure {
      
    } catch {
      XCTAssertFalse(true, "error type should be ParserFailure")
    }
  }
}

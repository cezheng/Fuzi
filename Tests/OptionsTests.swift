// XmlOptionsTests.swift
// Copyright (c) 2024 BPerlakiH
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
import libxml2

final class XmlOptionsTests: XCTestCase {

    func testXmlParseOptionValues() {
        XCTAssertEqual(XML_PARSE_NOWARNING.rawValue, XmlParseOptions.noWarning.rawValue)
        XCTAssertEqual(XML_PARSE_NOERROR.rawValue, XmlParseOptions.noError.rawValue)
        XCTAssertEqual(XML_PARSE_RECOVER.rawValue, XmlParseOptions.recover.rawValue)
    }

    func testXmlParseOptionSet() {
        let defaultOptions = UInt32(XML_PARSE_NOWARNING.rawValue | XML_PARSE_NOERROR.rawValue | XML_PARSE_RECOVER.rawValue)
        let options: XmlParseOptions = [.noWarning, .noError, .recover]
        XCTAssertEqual(options.rawValue, defaultOptions)
        XCTAssertEqual(XmlParseOptions.defaultOptions.rawValue, defaultOptions)
    }
}

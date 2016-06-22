// Document.swift
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

import Foundation
import libxml2

/// XML document which can be searched and queried.
public class XMLDocument {
  // MARK: - Document Attributes
  /// The XML version.
  public private(set) lazy var version: String? = {
    return ^-^self.cDocument.pointee.version
  }()
  
  /// The string encoding for the document. This is NSUTF8StringEncoding if no encoding is set, or it cannot be calculated.
  public private(set) lazy var encoding: String.Encoding = {
    if let encodingName = ^-^self.cDocument.pointee.encoding {
      let encoding = CFStringConvertIANACharSetNameToEncoding(encodingName)
      if encoding != kCFStringEncodingInvalidId {
        return String.Encoding(rawValue: UInt(CFStringConvertEncodingToNSStringEncoding(encoding)))
      }
    }
    return String.Encoding.utf8
  }()

  // MARK: - Accessing the Root Element
  /// The root element of the document.
  public private(set) var root: XMLElement?
  
  // MARK: - Accessing & Setting Document Formatters
  /// The formatter used to determine `numberValue` for elements in the document. By default, this is an `NSNumberFormatter` instance with `NSNumberFormatterDecimalStyle`.
  public lazy var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
  }()
  
  /// The formatter used to determine `dateValue` for elements in the document. By default, this is an `NSDateFormatter` instance configured to accept ISO 8601 formatted timestamps.
  public lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(localeIdentifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter
  }()
  
  // MARK: - Creating XML Documents
  private let cDocument: xmlDocPtr
  
  /**
  Creates and returns an instance of XMLDocument from an XML string, throwing XMLError if an error occured while parsing the XML.
  
  - parameter string:   The XML string.
  - parameter encoding: The string encoding.
  
  - throws: `XMLError` instance if an error occurred
  
  - returns: An `XMLDocument` with the contents of the specified XML string.
  */
  public convenience init(string: String, encoding: String.Encoding = String.Encoding.utf8) throws {
    guard let cChars = string.cString(using: encoding) else {
      throw XMLError.InvalidData
    }
    try self.init(cChars: cChars)
  }
  
  /**
  Creates and returns an instance of XMLDocument from XML data, throwing XMLError if an error occured while parsing the XML.
  
  - parameter data: The XML data.
  
  - throws: `XMLError` instance if an error occurred
  
  - returns: An `XMLDocument` with the contents of the specified XML string.
  */
  public convenience init(data: NSData) throws {
    try self.init(cChars: [CChar](UnsafeBufferPointer(start: UnsafePointer(data.bytes), count: data.length)))
  }
  
  /**
  Creates and returns an instance of XMLDocument from C char array, throwing XMLError if an error occured while parsing the XML.
  
  - parameter cChars: cChars The XML data as C char array
  
  - throws: `XMLError` instance if an error occurred
  
  - returns: An `XMLDocument` with the contents of the specified XML string.
  */
  public convenience init(cChars: [CChar]) throws {
    let options = Int32(XML_PARSE_NOWARNING.rawValue | XML_PARSE_NOERROR.rawValue | XML_PARSE_RECOVER.rawValue)
    try self.init(cChars: cChars, options: options)
  }
  
  private typealias ParseFunction = (UnsafePointer<Int8>?, Int32, UnsafePointer<Int8>?, UnsafePointer<Int8>?, Int32) -> xmlDocPtr?
  
  private convenience init(cChars: [CChar], options: Int32) throws {
    try self.init(parseFunction: { xmlReadMemory($0, $1, $2, $3, $4) }, cChars: cChars, options: options)
  }
  
  private convenience init(parseFunction: ParseFunction, cChars: [CChar], options: Int32) throws {
    guard let document = parseFunction(UnsafePointer(cChars), Int32(cChars.count), "", nil, options) else {
      throw XMLError.lastError(defaultError: .ParserFailure)
    }
    xmlResetLastError()
    self.init(cDocument: document)
  }
  
  private init(cDocument: xmlDocPtr) {
    self.cDocument = cDocument
    // cDocument shall not be nil
    root = XMLElement(cNode: xmlDocGetRootElement(cDocument), document: self)
  }
  
  deinit {
    xmlFreeDoc(cDocument)
  }
  
  // MARK: - XML Namespaces
  var defaultNamespaces = [String: String]()
  
  /**
  Define a prefix for a default namespace.
  
  - parameter prefix: The prefix name
  - parameter ns:     The default namespace URI that declared in XML Document
  */
  public func definePrefix(_ prefix: String, defaultNamespace ns: String) {
    defaultNamespaces[ns] = prefix
  }
}

extension XMLDocument: Equatable {}

/**
Determine whether two documents are the same

- parameter lhs: XMLDocument on the left
- parameter rhs: XMLDocument on the right

- returns: whether lhs and rhs are equal
*/
public func ==(lhs: XMLDocument, rhs: XMLDocument) -> Bool {
  return lhs.cDocument == rhs.cDocument
}

/// HTML document which can be searched and queried.
public class HTMLDocument: XMLDocument {
  // MARK: - Convenience Accessors
  
  /// HTML title of current document
  public var title: String? {
    return root?.firstChild(tag: "head")?.firstChild(tag: "title")?.stringValue
  }
  
  /// HTML head element of current document
  public var head: XMLElement? {
    return root?.firstChild(tag: "head")
  }
  
  /// HTML body element of current document
  public var body: XMLElement? {
    return root?.firstChild(tag: "body")
  }
  
  // MARK: - Creating HTML Documents
  /**
  Creates and returns an instance of HTMLDocument from C char array, throwing XMLError if an error occured while parsing the HTML.
  
  - parameter cChars: cChars The HTML data as C char array
  
  - throws: `XMLError` instance if an error occurred
  
  - returns: An `HTMLDocument` with the contents of the specified HTML string.
  */
  public convenience init(cChars: [CChar]) throws {
    let options = Int32(HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NOERROR.rawValue | HTML_PARSE_RECOVER.rawValue)
    try self.init(cChars: cChars, options: options)
  }
  
  private convenience init(cChars: [CChar], options: Int32) throws {
    try self.init(parseFunction: { htmlReadMemory($0, $1, $2, $3, $4) }, cChars: cChars, options: options)
  }
}

// Node.swift
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

public typealias XMLNodeType = xmlElementType

extension XMLNodeType {
  public static var Element: xmlElementType       { return XML_ELEMENT_NODE }
  public static var Attribute: xmlElementType     { return XML_ATTRIBUTE_NODE }
  public static var Text: xmlElementType          { return XML_TEXT_NODE }
  public static var CDataSection: xmlElementType  { return XML_CDATA_SECTION_NODE }
  public static var EntityRef: xmlElementType     { return XML_ENTITY_REF_NODE }
  public static var Entity: xmlElementType        { return XML_ENTITY_NODE }
  public static var Pi: xmlElementType            { return XML_PI_NODE }
  public static var Comment: xmlElementType       { return XML_COMMENT_NODE }
  public static var Document: xmlElementType      { return XML_DOCUMENT_NODE }
  public static var DocumentType: xmlElementType  { return XML_DOCUMENT_TYPE_NODE }
  public static var DocumentFrag: xmlElementType  { return XML_DOCUMENT_FRAG_NODE }
  public static var Notation: xmlElementType      { return XML_NOTATION_NODE }
  public static var HtmlDocument: xmlElementType  { return XML_HTML_DOCUMENT_NODE }
  public static var DTD: xmlElementType           { return XML_DTD_NODE }
  public static var ElementDecl: xmlElementType   { return XML_ELEMENT_DECL }
  public static var AttributeDecl: xmlElementType { return XML_ATTRIBUTE_DECL }
  public static var EntityDecl: xmlElementType    { return XML_ENTITY_DECL }
  public static var NamespaceDecl: xmlElementType { return XML_NAMESPACE_DECL }
  public static var XIncludeStart: xmlElementType { return XML_XINCLUDE_START }
  public static var XIncludeEnd: xmlElementType   { return XML_XINCLUDE_END }
  public static var DocbDocument: xmlElementType  { return XML_DOCB_DOCUMENT_NODE }
}

infix operator ~= {}
public func ~=(lhs: XMLNodeType, rhs: XMLNodeType) -> Bool {
  return lhs.rawValue == rhs.rawValue
}

public class XMLNode {
  /// The document containing the element.
  public unowned let document: XMLDocument
  
  /// The type of the XMLNode
  public var type: XMLNodeType
  
  /// The element's line number.
  public private(set) lazy var lineNumber: Int = {
    return xmlGetLineNo(self.cNode)
  }()
  
  // MARK: - Accessing Parent, Child, and Sibling Elements
  /// The element's parent element.
  public private(set) lazy var parent: XMLElement? = {
    return XMLElement(cNode: self.cNode.memory.parent, document: self.document)
  }()
  
  /// The element's next sibling.
  public private(set) lazy var previousSibling: XMLElement? = {
    return XMLElement(cNode: self.cNode.memory.prev, document: self.document)
  }()
  
  /// The element's previous sibling.
  public private(set) lazy var nextSibling: XMLElement? = {
    return XMLElement(cNode: self.cNode.memory.next, document: self.document)
  }()
  
  /// A string representation of the element's value.
  public private(set) lazy var stringValue : String = {
    let key = xmlNodeGetContent(self.cNode)
    let stringValue = ^-^key ?? ""
    xmlFree(key)
    return stringValue
  }()
  
  /// The raw XML string of the element.
  public private(set) lazy var rawXML: String = {
    let buffer = xmlBufferCreate()
    xmlNodeDump(buffer, self.cNode.memory.doc, self.cNode, 0, 0)
    let dumped = ^-^xmlBufferContent(buffer) ?? ""
    xmlBufferFree(buffer)
    return dumped
  }()
  
  internal let cNode: xmlNodePtr
  
  internal init?(cNode: xmlNodePtr, document: XMLDocument, type: XMLNodeType) {
    self.cNode = cNode
    self.type = type
    self.document = document
    if cNode == nil {
      return nil
    }
  }
}




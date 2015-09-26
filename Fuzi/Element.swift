// Element.swift
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

/// Represents an element in `XMLDocument` or `HTMLDocument`
public class XMLElement {
  /// The document containing the element.
  public let document: XMLDocument
  
  /// The element's namespace.
  public private(set) lazy var namespace: String? = {
    return ^-^(self.cNode.memory.ns != nil ?self.cNode.memory.ns.memory.prefix :nil)
  }()
  
  /// The element's tag.
  public private(set) lazy var tag: String? = {
    return ^-^self.cNode.memory.name
  }()
  
  /// The element's line number.
  public private(set) lazy var lineNumber: Int = {
    return xmlGetLineNo(self.cNode)
  }()
  
  // MARK: - Accessing Attributes
  /// All attributes for the element.
  public private(set) lazy var attributes: [String : String] = {
    var attributes = [String: String]()
    for var attribute = self.cNode.memory.properties; attribute != nil; attribute = attribute.memory.next {
      if let key = ^-^attribute.memory.name, let value = self.attr(key) {
        attributes[key] = value
      }
    }
    return attributes
  }()
  
  // MARK: - Accessing Parent, Child, and Sibling Elements
  /// The element's parent element.
  public private(set) lazy var parent: XMLElement? = {
    return XMLElement(cNode: self.cNode.memory.parent, document: self.document)
  }()
  
  /// The element's children elements.
  public var children: [XMLElement] {
    return LinkedCNodes(head: cNode.memory.children).map {
      XMLElement(cNode: $0, document: self.document)!
    }
  }
  
  /**
  Returns the first child element with a tag, or `nil` if no such element exists.
  
  - parameter tag: The tag name.
  - parameter ns:  The namespace, or `nil` by default if not using a namespace
  
  - returns: The child element.
  */
  public func firstChild(tag tag: String, inNamespace ns: String? = nil) -> XMLElement? {
    for var nodePtr = cNode.memory.children; nodePtr != nil; nodePtr = nodePtr.memory.next {
      if cXMLNodeMatchesTagInNamespace(nodePtr, tag: tag, ns: ns) {
        return XMLElement(cNode: nodePtr, document: self.document)
      }
    }
    return nil
  }
  
  /**
  Returns all children elements with the specified tag.
  
  - parameter tag: The tag name.
  - parameter ns:  The namepsace, or `nil` by default if not using a namespace
  
  - returns: The children elements.
  */
  public func children(tag tag: String, inNamespace ns: String? = nil) -> [XMLElement] {
    return LinkedCNodes(head: cNode.memory.children).filter {
      cXMLNodeMatchesTagInNamespace($0, tag: tag, ns: ns)
    }.map {
      XMLElement(cNode: $0, document: self.document)!
    }
  }
  
  /// The element's next sibling.
  public private(set) lazy var previousSibling: XMLElement? = {
    return XMLElement(cNode: self.cNode.memory.prev, document: self.document)
  }()
  
  /// The element's previous sibling.
  public private(set) lazy var nextSibling: XMLElement? = {
    return XMLElement(cNode: self.cNode.memory.next, document: self.document)
  }()
  
  // MARK: - Accessing Content
  /// Whether the element has a value.
  public var isBlank: Bool {
    return stringValue.isEmpty
  }
  
  /// A string representation of the element's value.
  public private(set) lazy var stringValue : String = {
    let key = xmlNodeGetContent(self.cNode)
    let stringValue = ^-^key ?? ""
    xmlFree(key)
    return stringValue
  }()
  
  /// A number representation of the element's value, which is generated from the document's `numberFormatter` property.
  public private(set) lazy var numberValue: NSNumber? = {
    return self.document.numberFormatter.numberFromString(self.stringValue)
  }()
  
  /// A date representation of the element's value, which is generated from the document's `dateFormatter` property.
  public private(set) lazy var dateValue: NSDate? = {
    return self.document.dateFormatter.dateFromString(self.stringValue)
  }()
  
  /**
  Returns the child element at the specified index.
  
  - parameter idx: The index.
  
  - returns: The child element.
  */
  public subscript (idx: Int) -> XMLElement? {
    return children[idx]
  }
  
  /**
  Returns the value for the attribute with the specified key.
  
  - parameter name: The attribute name.
  
  - returns: The attribute value, or `nil` if the attribute is not defined.
  */
  public subscript (name: String) -> String? {
    return attr(name)
  }

  /**
  Returns the value for the attribute with the specified key.
  
  - parameter name: The attribute name.
  - parameter ns:   The namespace, or `nil` by default if not using a namespace
  
  - returns: The attribute value, or `nil` if the attribute is not defined.
  */
  public func attr(name: String, namespace ns: String? = nil) -> String? {
    var value: String? = nil
    guard let attrChars = name.cStringUsingEncoding(document.encoding) else {
      return nil
    }
    
    let xmlValue: UnsafeMutablePointer<xmlChar>
    if let ns = ns, let nsChars = ns.cStringUsingEncoding(document.encoding) {
      xmlValue = xmlGetNsProp(cNode, UnsafePointer(attrChars), UnsafePointer(nsChars))
    } else {
      xmlValue = xmlGetProp(cNode, UnsafePointer(attrChars))
    }
    
    if xmlValue != nil {
      value = ^-^xmlValue
      xmlFree(xmlValue)
    }
    return value
  }
  
  /// The raw XML string of the element.
  public private(set) lazy var rawXML: String = {
    let buffer = xmlBufferCreate()
    xmlNodeDump(buffer, self.cNode.memory.doc, self.cNode, 0, 0)
    let dumped = ^-^xmlBufferContent(buffer) ?? ""
    xmlBufferFree(buffer)
    return dumped
  }()
  
  internal let cNode: xmlNodePtr
  
  internal init?(cNode: xmlNodePtr, document: XMLDocument) {
    self.cNode = cNode
    self.document = document
    if cNode == nil {
      return nil
    }
  }
}

extension XMLElement: Equatable {}

/**
Determine whether two element are the same

- parameter lhs: XMLElement on the left
- parameter rhs: XMLElement on the right

- returns: whether lhs and rhs are equal
*/
public func ==(lhs: XMLElement, rhs: XMLElement) -> Bool {
  return lhs.cNode == rhs.cNode
}
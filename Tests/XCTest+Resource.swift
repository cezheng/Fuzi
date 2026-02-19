//
//  XCTest+Resource.swift
//  
//
//  Created by Adrian Schönig on 22/9/21.
//

import Foundation
import XCTest

extension XCTestCase {
  func loadData(filename: String, extension fileExtension: String) throws -> Data {
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let path = thisDirectory.appendingPathComponent("Resources", isDirectory: true)
      .appendingPathComponent(filename)
      .appendingPathExtension(fileExtension)
    return try Data(contentsOf: path)
  }
}

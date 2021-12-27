import XCTest
import class Foundation.Bundle
@testable import downstream
import ArgumentParser

final class DownstreamTests: XCTestCase {
  func testCatchall() throws {
    let associations = AssociationsFile(associations: [
      "main.swift": ["www.maindocs.com", "anotherPlaceToFindDocs"],
      "unchangingFile.swift": ["www.unchangingDocs.edu"],
      "*": ["www.wholeDirectoryDocs.net"]
    ])

    let downstreamArgument = DownstreamArgument(files: ["main.swift"])

    let todos = try downstreamArgument.matches(forFile: "main.swift", associationsFile: associations)
    XCTAssertEqual(todos, ["www.wholeDirectoryDocs.net", "www.maindocs.com", "anotherPlaceToFindDocs"])
  }

  func testStandard() throws {
    let associations = AssociationsFile(associations: [
      "main.swift": ["www.maindocs.com", "anotherPlaceToFindDocs"],
      "unchangingFile.swift": ["www.unchangingDocs.edu"],
    ])

    let downstreamArgument = DownstreamArgument(files: ["main.swift"])

    let todos = try downstreamArgument.matches(forFile: "main.swift", associationsFile: associations)
    XCTAssertEqual(todos, ["www.maindocs.com", "anotherPlaceToFindDocs"])
  }

  func testMultipleInputFiles() throws {
    let topAssociations = AssociationsFile(associations: [
      "Package.swift": ["dependenciesDocs.com"]
    ])

    let sourceAssociations = AssociationsFile(associations: [
      "main.swift": ["www.maindocs.com", "anotherPlaceToFindDocs"],
      "unchangingFile.swift": ["www.unchangingDocs.edu"],
    ])

    let allAssociations = ["/": topAssociations, "/Source": sourceAssociations]

    let downstreamArgument = DownstreamArgument()
    let todos = try downstreamArgument.todos(fileList: ["/Source/main.swift", "/Package.swift"], associationsFiles: allAssociations)

    XCTAssertEqual(todos, [
      "/Source/main.swift": ["www.maindocs.com", "anotherPlaceToFindDocs"],
      "/Package.swift": ["dependenciesDocs.com"]
    ])
  }
}

//
//  File.swift
//  
//
//  Created by Alex Reilly on 10/24/20.
//

import ArgumentParser
import Foundation
import Files
import Yams

enum OutputFormat: String, ExpressibleByArgument {
  case json
  case yaml
  case humanFriendly = "human"
}

struct DownstreamArgument: ParsableCommand {
  @Option(name: .shortAndLong, help: "The format of the output")
  var outputFormat: OutputFormat?
  
  @Argument(help: "Input files")
  var files: [String]
  
  mutating func run() throws {
    let todoList = todos(fileList: self.files)
    let output = outputFactory(todos: todoList, format: outputFormat)
    
    print(output)
  }
  
  func todos(fileList: [String]) -> [String: [String]] {
    let decoder = YAMLDecoder()
    
    return fileList.reduce(into: [String: [String]]()) { (result, filePath) in
      let changedFile = try! File(path: filePath)
      
      if
        let parent = changedFile.parent,
        let downsteamYML = try? parent.file(named: "downstream.yml").read()
      {
        guard let associationsFile = try? decoder.decode(AssociationsFile.self, from: downsteamYML) else {
          print("\(parent.path)downstream.yml could not be parsed")
          DownstreamArgument.exit()
        }
        let fileName = changedFile.name
        let newTodos = associationsFile.associations[fileName]
        result[filePath] = newTodos
      }
    }
  }
  
  /// Formats the todo list in the selected format type. Defaults to .humanFriendly if no format type is provided.
  /// - Parameters:
  ///   - todos: Todo list in the form of changed file -> associated tasks
  ///   - format: How the list ought to be formatted. Defaults to .humanFriendly if no format type is provided
  /// - Returns: Todo list formatted as desired.
  func outputFactory(todos: [String: [String]], format: OutputFormat?) -> String {
    let format = format ?? .humanFriendly
    
    switch format {
    case .humanFriendly:
      return humanReadableOutput(todos: todos)
    case .json:
      return jsonOutput(todos: todos)
    case .yaml:
      return yamlOutput(todos: todos)
    }
  }
  
  func humanReadableOutput(todos: [String: [String]]) -> String {
    return todos.map { (filePath, todos) in
      return "Due to changes made to \(filePath), you may need to make updates to the following: \n \(todos.joined(separator: "\n"))"
    }.joined(separator: "\n")
  }
  
  func jsonOutput(todos: [String: [String]]) -> String {
    let encoder = JSONEncoder()
    guard
      let jsonData = try? encoder.encode(todos),
      let jsonString = String(data: jsonData, encoding: .utf8)
    else {
      print("Todo list could not be encoded to JSON string. \n List: \(todos)")
      Self.exit()
    }
    
    return jsonString
  }
  
  func yamlOutput(todos: [String: [String]]) -> String {
    let encoder = YAMLEncoder()
    guard
      let yamlString = try? encoder.encode(todos)
    else {
      print("Todo list could not be encoded to YAML string. \n List: \(todos)")
      Self.exit()
    }
    
    return yamlString
  }
}

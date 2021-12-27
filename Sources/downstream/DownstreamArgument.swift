import ArgumentParser
import Foundation
import Yams

enum OutputFormat: String, ExpressibleByArgument {
  case json
  case yaml
  case list
  case humanFriendly = "human"
}

typealias TodoList = [String: [String]]

extension TodoList {
    func matches(_ filename: String) -> [String] {
        let results = [self["*"], self[filename]].compactMap { $0 }.flatMap { $0 }
        return results
    }
}

struct DownstreamArgument: ParsableCommand {
  @Option(name: .shortAndLong, help: "The format of the output")
  var outputFormat: OutputFormat = .humanFriendly
  
  @Argument(help: "Input files")
  var files: [String] = []

  mutating func run() throws {
    let todoList = try todos(fileList: self.files)
    let output = outputFactory(todos: todoList, format: outputFormat)
    
    print(output)
  }

  // Associations file is used in place of an actual file during tests
  func todos(fileList: [String]) throws -> TodoList {
    return try fileList.reduce(into: TodoList()) { (result, filePath) in
      result[filePath] = try matches(forFile: filePath)
    }
  }

  func matches(forFile path: String, associationsFile: AssociationsFile?=nil) throws -> [String] {
    let decoder = YAMLDecoder()

    if let associationsFile = associationsFile {
      return associationsFile.associations.matches(path)
    } else {
      // This path should be coming from git diff, so we expect it to be valid
      let changedFile = URL(fileURLWithPath: path)
      let parent = changedFile.deletingLastPathComponent()
      let downstreamYML = changedFile.appendingPathComponent("downstream.yml")

      if
        let contentData = FileManager.default.contents(atPath: downstreamYML.path),
        let associations = String(data: contentData, encoding: .utf8)
      {
        guard let associationsFile = try? decoder.decode(AssociationsFile.self, from: associations) else {
          throw ValidationError("\(parent.path)downstream.yml could not be parsed")
        }
        let fileName = changedFile.lastPathComponent
        return associationsFile.associations.matches(fileName)
      }
    }

    return []
  }
  
  /// Formats the todo list in the selected format type. Defaults to .humanFriendly if no format type is provided.
  /// - Parameters:
  ///   - todos: Todo list in the form of changed file -> associated tasks
  ///   - format: How the list ought to be formatted. Defaults to .humanFriendly if no format type is provided
  /// - Returns: Todo list formatted as desired.
  func outputFactory(todos: TodoList, format: OutputFormat?) -> String {
    let format = format ?? .humanFriendly
    
    switch format {
    case .humanFriendly:
      return humanReadableOutput(todos: todos)
    case .json:
      return jsonOutput(todos: todos)
    case .yaml:
      return yamlOutput(todos: todos)
    case .list:
      return listOutput(todos: todos)
    }
  }
  
  func humanReadableOutput(todos: TodoList) -> String {
    return todos.map { (filePath, todos) in
      return "Due to changes made to \(filePath), you may need to make updates to the following: \n \(todos.joined(separator: "\n"))"
    }.joined(separator: "\n")
  }
  
  func jsonOutput(todos: TodoList) -> String {
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
  
  func yamlOutput(todos: TodoList) -> String {
    let encoder = YAMLEncoder()
    guard
      let yamlString = try? encoder.encode(todos)
    else {
      print("Todo list could not be encoded to YAML string. \n List: \(todos)")
      Self.exit()
    }
    
    return yamlString
  }
  
  func listOutput(todos: TodoList) -> String {
    return Set(todos.values).map { $0.joined(separator: "\n") }.joined(separator: "\n")
  }
}

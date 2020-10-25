//
//  main.swift
//  Downstream
//
//  Created by Alex Reilly on 10/22/20.
//

import Yams
import Files
import Foundation

let decoder = YAMLDecoder()

let fileList = Array(CommandLine.arguments[1...])

func todos(fileList: [String]) -> [String: [String]] {
  return fileList.reduce(into: [String: [String]]()) { (result, filePath) in
    let changedFile = try! File(path: filePath)
    
    if
      let parent = changedFile.parent,
      let downsteamYML = try? parent.file(named: "downstream.yml").read()
    {
      guard let associationsFile = try? decoder.decode(AssociationsFile.self, from: downsteamYML) else {
        print("\(parent.path)downstream.yml could not be parsed")
        exit(1)
      }
      let fileName = changedFile.name
      let newTodos = associationsFile.associations[fileName]
      result[filePath] = newTodos
    }
  }
}

func humanReadableOutput(todos: [String: [String]]) -> String {
  return foundTodos.map { (filePath, todos) in
    return "Due to changes made to \(filePath), you may need to make updates to the following: \n \(todos.joined(separator: "\n"))"
  }.joined(separator: "\n\n")
}

let foundTodos = todos(fileList: fileList)
let humanReadable = humanReadableOutput(todos: foundTodos)

print(humanReadable)

exit(0)

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

let fileList = CommandLine.arguments[1...]
let todos = fileList.flatMap { filePath -> [String] in
  let changedFile = try! File(path: filePath)
  
//  print("filePath", filePath)
//  print("parent", changedFile.parent?.path)
//  print("yaml", try? changedFile.parent?.file(named: "downstream.yml").read())
//  let associationsData = (try? changedFile.parent?.file(named: "downstream.yml").read() as? Data).flatMap { try? decoder.decode(AssociationsFile.self, from: $0) }
//  print("associations", associationsData)
  
  
  if
    let parent = changedFile.parent,
    let downsteamYML = try? parent.file(named: "downstream.yml").read()
  {
    guard let associationsFile = try? decoder.decode(AssociationsFile.self, from: downsteamYML) else {
      print("\(parent.path)downstream.yml could not be parsed")
      exit(1)
    }
    let fileName = changedFile.name
    let newTodos = associationsFile.associations[fileName] ?? []
    return newTodos.map {
      "Our records indicate that you may need to update the docs at \($0) because changes were made to  \(fileName)"
    }
  }
  
  return []
}

if !todos.isEmpty {
  todos.forEach {
    print($0)
  }
}

exit(0)
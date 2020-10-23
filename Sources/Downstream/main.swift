//
//  main.swift
//  Downstream
//
//  Created by Alex Reilly on 10/22/20.
//

import Yams
import Files

let yaml = """
associations:
  name: Martin D'vloper
  job: Developer
  skill: Elite
"""

let decoder = YAMLDecoder()
let associations = try! decoder.decode(AssociationsFile.self, from: yaml)

//print(associations)

let fileList = CommandLine.arguments[1...]
let todos = fileList.compactMap { filePath -> String? in
  let changedFile = try! File(path: filePath)
  
  if
    let parent = changedFile.parent,
    let downsteamYML = try? parent.file(named: "downstream.yml").read(),
    let associationsFile = try? decoder.decode(AssociationsFile.self, from: downsteamYML)
  {
    let fileName = changedFile.path(relativeTo: parent)
    return associationsFile.associations[fileName]
  }
  
  return nil
}

print(todos)

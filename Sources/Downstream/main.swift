//
//  main.swift
//  Downstream
//
//  Created by Alex Reilly on 10/22/20.
//

import Yams

let yaml = """
associations:
  name: Martin D'vloper
  job: Developer
  skill: Elite
"""

let decoder = YAMLDecoder()
let associations = try! decoder.decode(AssociationsFile.self, from: yaml)

print(associations)


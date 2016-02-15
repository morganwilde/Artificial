//
//  Cell.swift
//  Emag
//
//  Created by Morgan Wilde on 13/02/2016.
//  Copyright © 2016 Morgan Wilde. All rights reserved.
//

import Foundation

class Cell: Hashable {
  enum Kind: String {
    case Empty = "."
    case Source = "s"
    case Target = "t"
    case Obstacle = "o"
    case Intelligence = "i"
    case Unknown
    
    init (string: String) {
      switch string {
        case Empty.rawValue: self = Empty
        case Source.rawValue: self = Source
        case Target.rawValue: self = Target
        case Obstacle.rawValue: self = Obstacle
        case Intelligence.rawValue: self = Intelligence
        default: self = Unknown
      }
    }
  }
  
  struct Coordinate {
    let row: Int
    let column: Int
  }
  
  var kind: Kind
  var coordinate: Coordinate!
  var hashValue: Int {
    return coordinate.row.hashValue ^ coordinate.column.hashValue
  }
  
  init (kind: Kind) {
    self.kind = kind
  }
  convenience init (kind: String) {
    self.init(kind: Cell.Kind(string: kind))
  }
}

func == (left: Cell, right: Cell) -> Bool {
  return (
    left.coordinate.row == right.coordinate.row &&
    left.coordinate.column == right.coordinate.column
  )
}
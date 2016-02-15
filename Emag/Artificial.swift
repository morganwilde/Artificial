//
//  Artificial.swift
//  Emag
//
//  Created by Morgan Wilde on 14/02/2016.
//  Copyright © 2016 Morgan Wilde. All rights reserved.
//

import Foundation

class Artificial {
  enum Direction: Int {
    case Forward = 1
    case Right = 2
    case Backward = 3
    case Left = 4
    case Unknown
  }
  
  var direction: Direction
  
  init (direction: Direction) {
    self.direction = direction
  }
}

extension Artificial {
  func turnTo (direction: Direction) {
    self.direction = direction
  }
}
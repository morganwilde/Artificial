//
//  Grid.swift
//  Emag
//
//  Created by Morgan Wilde on 13/02/2016.
//  Copyright © 2016 Morgan Wilde. All rights reserved.
//

import Foundation

class Grid {
  var cells = [Cell]()
  let rowCount: Int
  let columnCount: Int
  
  // Lazy properties
  lazy var sourceCell: Cell? = {
    return self.findSourceCell()
  }()
  lazy var targetCell: Cell? = {
    return self.findTargetCell()
  }()
  
  init (level: String) {
    let rows = level.componentsSeparatedByString("\n")
    let rowCount = rows.count
    var columnCount = 0
    
    // Add cells
    for row in rows {
      columnCount = row.characters.count
      for column in row.characters {
        cells.append(
          Cell(kind: String(column))
        )
      }
    }
    
    self.rowCount = rowCount
    self.columnCount = columnCount
    
    // Second pass to store coordinates
    var cellNumber = 0
    for cell in cells {
      cell.coordinate = Cell.Coordinate(row: cellNumber / rowCount, column: cellNumber % rowCount)
      cellNumber += 1
    }
  }
  convenience init? (filename: String) {
    let resourcePath = NSBundle.mainBundle().pathForResource(filename, ofType: "grid")
    do {
      let contents = try String(contentsOfFile: resourcePath!, encoding: NSUTF8StringEncoding)
      self.init(level: contents)
    } catch {
      print(error)
      return nil
    }
  }
}

// MARK: Introspection

extension Grid {
  func findCellWithNumber (number: Int) -> Cell {
    return cells[number]
  }
  func findCellAtCoordinate (row row: Int, column: Int) -> Cell {
    return findCellWithNumber(row * columnCount + column)
  }
  func findSourceCell () -> Cell? {
    sourceCell = findCellOfKind(.Source)
    return sourceCell
  }
  func findTargetCell () -> Cell? {
    targetCell = findCellOfKind(.Target)
    return targetCell
  }
  func findCellOfKind (kind: Cell.Kind) -> Cell? {
    var cellNumber = 0
    for cell in cells {
      if (cell.kind == kind) {
        return findCellWithNumber(cellNumber)
      }
      cellNumber += 1
    }
    
    return nil
  }
  func calculateIntelligenceCount () -> Int {
    var count = 0
    for cell in cells {
      if cell.kind == .Intelligence {
        count += 1
      }
    }
    
    return count
  }
}

// MARK: Artificial Intelligence

extension Grid {
  func findNeighborsOfCell (cell: Cell) -> [Cell] {
    let rowAhead: Int? = (cell.coordinate.row + 1) < rowCount ? cell.coordinate.row + 1 : nil
    let rowBehind: Int? = cell.coordinate.row > 0 ? cell.coordinate.row - 1 : nil
    let columnLeft: Int? = (cell.coordinate.column + 1) < columnCount ? cell.coordinate.column + 1 : nil
    let columnRight: Int? = cell.coordinate.column > 0 ? cell.coordinate.column - 1 : nil
    
    var neighbors = [Cell]()
    if let rowAhead = rowAhead {
      let cell = findCellAtCoordinate(row: rowAhead, column: cell.coordinate.column)
      if cell.kind != .Obstacle {
        neighbors.append(cell)
      }
    }
    if let rowBehind = rowBehind {
      let cell = findCellAtCoordinate(row: rowBehind, column: cell.coordinate.column)
      if cell.kind != .Obstacle {
        neighbors.append(cell)
      }
    }
    if let columnLeft = columnLeft {
      let cell = findCellAtCoordinate(row: cell.coordinate.row, column: columnLeft)
      if cell.kind != .Obstacle {
        neighbors.append(cell)
      }
    }
    if let columnRight = columnRight {
      let cell = findCellAtCoordinate(row: cell.coordinate.row, column: columnRight)
      if cell.kind != .Obstacle {
        neighbors.append(cell)
      }
    }
    
    return neighbors
  }
  func findDistanceFromCell (cellFrom: Cell, toCell cellTo: Cell) -> Double {
    return sqrt(
      pow(Double(cellTo.coordinate.row - cellFrom.coordinate.row), 2) +
      pow(Double(cellTo.coordinate.column - cellFrom.coordinate.column), 2)
    )
  }
  func findCellDistanceToTarget (cell: Cell) -> Double? {
    if let target = targetCell {
      return findDistanceFromCell(cell, toCell: target)
    }
    return nil
  }
  func findPathFromTargetToSource () -> [Cell] {
    guard let source = sourceCell else {
      return [Cell]()
    }
    
    // Setup
    var exploredCells = Set<Cell>()
    var candidateCells = Set<Cell>(arrayLiteral: source)
    var traversal = [Cell: Cell]()
    
    var gScore = [Cell: Double]()
    var fScore = [Cell: Double]()
    
    // Helper functions
    func findCandidateWithMinScore () -> Cell {
      var minScore = Double.infinity
      var minCell: Cell!
      for candidate in candidateCells {
        if fScore[candidate] < minScore {
          minScore = fScore[candidate]!
          minCell = candidate
        }
      }
      
      return minCell
    }
    func createCellSequence () -> [Cell] {
      var current = targetCell!
      var sequence = [current]
      
      while traversal.keys.contains(current) {
        current = traversal[current]!
        sequence.append(current)
      }
      
      return sequence
    }
    
    for cell in cells {
      gScore[cell] = Double.infinity
      fScore[cell] = Double.infinity
    }
    gScore[source] = 0
    fScore[source] = findCellDistanceToTarget(source)
    
    while candidateCells.first != nil {
      let current = findCandidateWithMinScore()
      if current == targetCell {
        return createCellSequence()
      }
      
      candidateCells.remove(current)
      exploredCells.insert(current)
      
      let neighbors = findNeighborsOfCell(current)
      for neighbor in neighbors {
        if exploredCells.contains(neighbor) {
          continue
        }
        let tentativeGScore = gScore[current]! + findDistanceFromCell(current, toCell: neighbor)
        if !candidateCells.contains(neighbor) {
          candidateCells.insert(neighbor)
        } else if tentativeGScore >= gScore[neighbor] {
          continue
        }
        
        traversal[neighbor] = current
        
        gScore[neighbor] = tentativeGScore
        fScore[neighbor] = tentativeGScore + findDistanceFromCell(neighbor, toCell: targetCell!)
      }
    }
    
    return createCellSequence()
  }
}
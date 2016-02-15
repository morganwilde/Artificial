//
//  SceneViewController.swift
//  Emag
//
//  Created by Morgan Wilde on 13/02/2016.
//  Copyright © 2016 Morgan Wilde. All rights reserved.
//

import UIKit
import SceneKit

func degreesToRadians(degrees: Float) -> Float {
    return (degrees / 180) * Float(M_PI)
}
func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
}
func * (left: SCNVector3, right: Float) -> SCNVector3 {
  return SCNVector3(left.x * right, left.y * right, left.z * right)
}

class SceneViewController: UIViewController {
  // Rotations
  static let cameraRotation = SCNVector3(degreesToRadians(-35.264), degreesToRadians(-45), 0)
  static let lightRotation = SCNVector3(degreesToRadians(-50), degreesToRadians(-25), 0)
  
  // Sizing
  static let cellWidth: CGFloat = 2.5
  static let cellHeight: CGFloat = 0.1
  static let cellLength: CGFloat = 2.5
  static let cellPadding: CGFloat = 0.2
  var cellRows: Int {
    return grid.rowCount
  }
  var cellColumns: Int {
    return grid.columnCount
  }
  var gridWidth: CGFloat {
    return CGFloat(cellColumns) * (SceneViewController.cellWidth + SceneViewController.cellPadding)
  }
  let gridHeight: CGFloat = 1
  var gridLength: CGFloat {
    return CGFloat(cellRows) * (SceneViewController.cellLength + SceneViewController.cellPadding)
  }
  static let heroWidth = cellWidth
  static let heroHeight: CGFloat = 4
  static let heroLength = cellLength
  static let heroHoverDistance: CGFloat = 0.1
  
  // Colors
  static let cellColor = UIColor(hex: "#7f8c8d") // Asbestos
  static let gridColor = UIColor(hex: "#bdc3c7")
  static let gridWallColor = UIColor(hex: "#ecf0f1")
  static let heroColor = UIColor(hex: "#ffffff") // White
  
  // Outlets
  @IBOutlet weak var sceneView: SCNView!
  
  // Models
  var grid: Grid!
  var artificial: Artificial!
  var heroActivePercentage: CGFloat = 0.1
  
  // Views
  var scene: SCNScene!
  var lightNode: SCNNode!
  var gridNode: SCNNode!
  var heroNode: SCNNode!
}

// MARK: Grid

extension SceneViewController {
  func sceneSetup () {
    print("sceneSetup")
  }
}

// MARK: View lifecycle

extension SceneViewController {
  override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBarHidden = true
    super.viewWillAppear(animated)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    createWorld()
    drawWorld()
  }
}

// MARK: View Controller settings

extension SceneViewController {
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

// MARK: Events

extension SceneViewController {
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
//    guard let touch = touches.first else {
//      return
//    }
//    let location = touch.locationInView(sceneView)
//    var cell: SCNNode?
//    let hitTestResults = sceneView.hitTest(location, options: nil)
//    for hitTestResult in hitTestResults {
//      if hitTestResult.node.name == "Cell" {
//        cell = hitTestResult.node
//      }
//    }
//    
//    if let cell = cell {
//      let (x, z) = rowAndColumnForPosition(cell.position)
//      moveHeroToRow(z, column: x)
//    }
    
    find()
  }
  func moveHeroToRow (row: Int, column: Int, previousRow: Int?, previousColumn: Int?) -> [SCNAction] {
    let sourcePosition: SCNVector3
    if let previousRow = previousRow, let previousColumn = previousColumn {
      sourcePosition = heroPositionForRow(previousRow, column: previousColumn)
    } else {
      sourcePosition = heroNode.position
    }
    let targetPosition = heroPositionForRow(row, column: column)
    let deltaX = targetPosition.x - sourcePosition.x
    let deltaZ = targetPosition.z - sourcePosition.z
    
    let middle = SCNVector3(
      sourcePosition.x + deltaX / 2,
      sourcePosition.y,
      sourcePosition.z + deltaZ / 2
    )

    return [
      SCNAction.moveTo(middle + SCNVector3(0, 1, 0), duration: 0.25),
      SCNAction.moveTo(targetPosition, duration: 0.25),
      SCNAction.waitForDuration(0.1)
    ]
  }
  func rowAndColumnForPosition (position: SCNVector3) -> (row: Int, column: Int) {
    let offsetX = -gridWidth/2 + SceneViewController.cellWidth/2 + SceneViewController.cellPadding/2
    let offsetZ = -gridLength/2 + SceneViewController.cellLength/2 + SceneViewController.cellPadding/2
    
    let x = (position.x - Float(offsetX)) / Float(SceneViewController.cellWidth + SceneViewController.cellPadding)
    let z = (position.z - Float(offsetZ)) / Float(SceneViewController.cellLength + SceneViewController.cellPadding)
    
    return (Int(x), Int(z))
  }
}

// MARK: Create Model

extension SceneViewController {
  func createWorld () {
    grid = Grid(filename: "level")
//    grid = Grid(filename: "level-1")
    //grid = Grid(filename: "level-2")
  }
}

// MARK: Create things

extension SceneViewController {
  func createScene () {
    scene = SCNScene()
    sceneView.scene = scene
    sceneView.allowsCameraControl = true
  }
  func createCamera () {
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    camera.name = "WorldCamera"
    camera.zNear = -100.0
    camera.zFar = 100.0
    camera.xFov = 0
    camera.yFov = 0
    camera.usesOrthographicProjection = true
    camera.orthographicScale = 10
    
    cameraNode.camera = camera
    cameraNode.eulerAngles = SceneViewController.cameraRotation
    cameraNode.position = SCNVector3(0, 0, 0)
    
    scene.rootNode.addChildNode(cameraNode)
  }
  func createLights () {
    let directionalLightNode = SCNNode()
    directionalLightNode.light = SCNLight()
    directionalLightNode.light!.type = SCNLightTypeDirectional
    directionalLightNode.eulerAngles = SceneViewController.lightRotation
    scene.rootNode.addChildNode(directionalLightNode)
  }
  func createGridWithRows (rows: Int, columns: Int) {
    let diffuseColorMaterial = SCNMaterial()
    diffuseColorMaterial.diffuse.contents = SceneViewController.gridColor
    
    let gridWidth = CGFloat(columns) * (SceneViewController.cellWidth + SceneViewController.cellPadding) + SceneViewController.cellPadding/2
    let gridLength = CGFloat(rows) * (SceneViewController.cellLength + SceneViewController.cellPadding) + SceneViewController.cellPadding/2
    
    let box = SCNBox(
      width: gridWidth,
      height: gridHeight,
      length: gridLength,
      chamferRadius: 0)
    box.materials = [diffuseColorMaterial]
    
    gridNode = SCNNode(geometry: box)
    gridNode.position = SCNVector3(0, 0, 0)
    
    // Walls
    let wallWidth: CGFloat = gridLength
    let wallHeight: CGFloat = 10
    let wallLength: CGFloat = gridHeight
    
    let wallMaterial = SCNMaterial()
    wallMaterial.diffuse.contents = SceneViewController.gridWallColor
    
    // Back Wall
    let backWallGeometry = SCNBox(width: wallWidth, height: wallHeight, length: wallLength, chamferRadius: 0)
    backWallGeometry.firstMaterial = wallMaterial
    let backWallNode = SCNNode(geometry: backWallGeometry)
    backWallNode.position = SCNVector3(
      0,
      wallHeight/2 - gridHeight/2,
      -(gridWidth/2 + wallLength/2)
    )
    
    // Side Wall
    let sideWallGeometry = SCNBox(width: wallLength, height: wallHeight, length: wallWidth, chamferRadius: 0)
    sideWallGeometry.firstMaterial = wallMaterial
    let sideWallNode = SCNNode(geometry: sideWallGeometry)
    sideWallNode.position = SCNVector3(
      gridWidth/2 + wallLength/2,
      wallHeight/2 - gridHeight/2,
      0
    )
    
    gridNode.addChildNode(backWallNode)
    gridNode.addChildNode(sideWallNode)
    
    // Light
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light?.type = SCNLightTypeSpot
    lightNode.light?.castsShadow = true
    lightNode.light?.zFar = 100
    lightNode.light?.zNear = 1
    lightNode.light?.shadowBias = 100
    lightNode.position = SCNVector3(0, 75, 0)
    lightNode.eulerAngles = SCNVector3(
      degreesToRadians(-90),
      0,
      0)
    
    gridNode.addChildNode(lightNode)
    
    scene.rootNode.addChildNode(gridNode)
  }
  func createCells () {
    
    let offsetX = -gridWidth/2 + SceneViewController.cellWidth/2 + SceneViewController.cellPadding/2
    let offsetZ = -gridLength/2 + SceneViewController.cellLength/2 + SceneViewController.cellPadding/2
    
    for row in 0..<cellRows {
      for column in 0..<cellColumns {
        let diffuseColorMaterial = SCNMaterial()
        diffuseColorMaterial.diffuse.contents = SceneViewController.cellColor
        
        let box = SCNBox(
          width: SceneViewController.cellWidth,
          height: SceneViewController.cellHeight,
          length: SceneViewController.cellLength,
          chamferRadius: 0)
        box.materials = [diffuseColorMaterial]
        
        let x = Float(SceneViewController.cellWidth + SceneViewController.cellPadding) * Float(column)
        let y = Float(SceneViewController.cellLength + SceneViewController.cellPadding) * Float(row)
        
        let cellNode = SCNNode(geometry: box)
        cellNode.name = "Cell"
        cellNode.position = SCNVector3(
          x + Float(offsetX),
          Float(gridHeight/2 + SceneViewController.cellHeight/2),
          y + Float(offsetZ)
        )
        gridNode.addChildNode(cellNode)
      }
    }
  }
  func createHeroPositionedAtRow (row: Int, column: Int) {
    let heroGeometry = SCNBox(
      width: SceneViewController.heroWidth,
      height: SceneViewController.heroHeight,
      length: SceneViewController.heroLength,
      chamferRadius: 0)
    let heroMaterial = SCNMaterial()
    heroMaterial.diffuse.contents = SceneViewController.heroColor
    heroGeometry.firstMaterial = heroMaterial
    
    let activeHeight = SceneViewController.heroHeight * (heroActivePercentage)
    let inactiveHeight = SceneViewController.heroHeight * (1 - heroActivePercentage)
    
    let activeHeroMaterial = SCNMaterial()
    activeHeroMaterial.diffuse.contents = SceneViewController.heroColor
    let inactiveHeroMaterial = SCNMaterial()
    inactiveHeroMaterial.diffuse.contents = SceneViewController.heroColor.colorWithAlphaComponent(0.25)
    
    let activeHeroGeometry = SCNBox(
      width: SceneViewController.heroWidth,
      height: activeHeight,
      length: SceneViewController.heroLength,
      chamferRadius: 0
    )
    activeHeroGeometry.firstMaterial = activeHeroMaterial
    let inactiveHeroGeometry = SCNBox(
      width: SceneViewController.heroWidth,
      height: inactiveHeight,
      length: SceneViewController.heroLength,
      chamferRadius: 0
    )
    inactiveHeroGeometry.firstMaterial = inactiveHeroMaterial
    
    let activeHero = SCNNode(geometry: activeHeroGeometry)
    activeHero.position = SCNVector3(0, -(inactiveHeight/2), 0)
    let inactiveHero = SCNNode(geometry: inactiveHeroGeometry)
    inactiveHero.position = SCNVector3(0, activeHeight/2, 0)
    
    heroNode = SCNNode()
    heroNode.addChildNode(activeHero)
    heroNode.addChildNode(inactiveHero)
    
    heroNode.position = heroPositionForRow(row, column: column)
    
    gridNode.addChildNode(heroNode)
  }
  func createGoal () {
    let width: CGFloat = SceneViewController.cellWidth
    let height: CGFloat = SceneViewController.heroHeight / 3
//    let goalGeometry = SCNTorus(ringRadius: width / 2, pipeRadius: height / 2)
    let geometry = SCNPyramid(width: width, height: height, length: width)
    let material = SCNMaterial()
    material.diffuse.contents = UIColor(hex: "#e74c3c")
    geometry.firstMaterial = material
    
    let goalNode = SCNNode(geometry: geometry)
    
    if let targetCell = grid.findTargetCell() {
      goalNode.position = positionForRow(targetCell.coordinate.row,
        column: targetCell.coordinate.column,
        nodeHeight: height)
    }
    
    goalNode.position.y += Float(SceneViewController.heroHeight/2 + height + 0.1)
    goalNode.eulerAngles = SCNVector3(0, 0, 0)
    
    gridNode.addChildNode(goalNode)
  }
  func createObstacles () {
    let obstacleHeight: CGFloat = 0.6
    let obstaclePadding: CGFloat = 0.3
    let obstacleBottomHeight = obstacleHeight
    let obstacleMiddleHeight = obstacleHeight / 2
    let obstacleTopHeight = obstacleHeight / 4
    
    let obstacleBottomBox = SCNBox(
      width: SceneViewController.cellWidth,
      height: obstacleBottomHeight,
      length: SceneViewController.cellLength,
      chamferRadius: 0
    )
    let obstacleMiddleBox = SCNBox(
      width: SceneViewController.cellWidth,
      height: obstacleMiddleHeight,
      length: SceneViewController.cellLength,
      chamferRadius: 0
    )
    let obstacleTopBox = SCNBox(
      width: SceneViewController.cellWidth,
      height: obstacleTopHeight,
      length: SceneViewController.cellLength,
      chamferRadius: 0
    )
    
    let obstacleMaterial = SCNMaterial()
    obstacleMaterial.diffuse.contents = UIColor(hex: "#2c3e50")
    let obstacleTopMaterial = SCNMaterial()
    obstacleTopMaterial.diffuse.contents = UIColor(hex: "#2c3e50").colorWithAlphaComponent(1)
    
    obstacleBottomBox.firstMaterial = obstacleMaterial
    obstacleMiddleBox.firstMaterial = obstacleMaterial
    obstacleTopBox.firstMaterial = obstacleTopMaterial
    
    // Create Nodes
    let offsetX = -gridWidth/2 + SceneViewController.cellWidth/2 + SceneViewController.cellPadding/2
    let offsetZ = -gridLength/2 + SceneViewController.cellLength/2 + SceneViewController.cellPadding/2
    let offsetY = Float(gridHeight/2 + SceneViewController.cellHeight/2)
    
    for row in 0..<cellRows {
      for column in 0..<cellColumns {
        let cell = grid.findCellAtCoordinate(row: row, column: column)
        if cell.kind == .Obstacle {
          let x = Float(SceneViewController.cellWidth + SceneViewController.cellPadding) * Float(column)
          let y = Float(SceneViewController.cellLength + SceneViewController.cellPadding) * Float(row)
          
          let obstacleBottom = SCNNode(geometry: obstacleBottomBox)
          let obstacleMiddle = SCNNode(geometry: obstacleMiddleBox)
          let obstacleTop = SCNNode(geometry: obstacleTopBox)
          
          obstacleBottom.position = SCNVector3(
            x + Float(offsetX),
            offsetY + Float(obstacleBottomHeight/2),
            y + Float(offsetZ)
          )
          obstacleMiddle.position = SCNVector3(
            x + Float(offsetX),
            offsetY + Float(obstacleBottomHeight/2) + Float(obstacleMiddleHeight + obstaclePadding),
            y + Float(offsetZ)
          )
          obstacleTop.position = SCNVector3(
            x + Float(offsetX),
            offsetY + Float(obstacleBottomHeight/2) + Float(obstacleMiddleHeight + obstaclePadding) + Float(obstacleTopHeight + obstaclePadding),
            y + Float(offsetZ)
          )
          gridNode.addChildNode(obstacleBottom)
          gridNode.addChildNode(obstacleMiddle)
          gridNode.addChildNode(obstacleTop)
        }
      }
    }
  }
  func createIntelligence () {
    let height: CGFloat = 1
    let padding: CGFloat = SceneViewController.heroHeight/4 + height/2
    
    let box = SCNBox(
      width: height,
      height: height,
      length: height,
      chamferRadius: 0
    )
    
    let material = SCNMaterial()
    material.diffuse.contents = UIColor(hex: "#2980b9")
    
    box.firstMaterial = material
    
    // Create Nodes
    let offsetX = -gridWidth/2 + SceneViewController.cellWidth/2 + SceneViewController.cellPadding/2
    let offsetZ = -gridLength/2 + SceneViewController.cellLength/2 + SceneViewController.cellPadding/2
    let offsetY = Float(gridHeight/2 + SceneViewController.cellHeight/2)
    
    let hoverUp = SCNAction.moveBy(SCNVector3(x: 0, y: Float(height/2), z: 0), duration: 0.5)
    let hoverDown = SCNAction.moveBy(SCNVector3(x: 0, y: Float(-height/2), z: 0), duration: 0.5)
    
    for row in 0..<cellRows {
      for column in 0..<cellColumns {
        let cell = grid.findCellAtCoordinate(row: row, column: column)
        if cell.kind == .Intelligence {
          let x = Float(SceneViewController.cellWidth + SceneViewController.cellPadding) * Float(column)
          let y = Float(SceneViewController.cellLength + SceneViewController.cellPadding) * Float(row)
          
          let intelligence = SCNNode(geometry: box)
          
          intelligence.position = SCNVector3(
            x + Float(offsetX),
            offsetY + Float(padding),
            y + Float(offsetZ)
          )
          intelligence.runAction(SCNAction.repeatActionForever(SCNAction.sequence([
            hoverUp,
            hoverDown
          ])))
          intelligence.name = "Intelligence=" + String(row) + "," + String(column)
          gridNode.addChildNode(intelligence)
        }
      }
    }
  }
  func drawWorld () {
    createScene()
    createCamera()
    createLights()
    createGridWithRows(cellRows, columns: cellColumns)
    createCells()
    createObstacles()
    createIntelligence()
    let source = grid.sourceCell!
    createHeroPositionedAtRow(source.coordinate.row, column: source.coordinate.column)
    createGoal()
  }
}

// MARK: Change things

extension SceneViewController {
  func heroPositionForRow (row: Int, column: Int) -> SCNVector3 {
    let heroPositionAboveCell = SCNVector3(0, SceneViewController.heroHoverDistance + SceneViewController.heroHeight/2, 0)
    return positionForRow(row, column: column) + heroPositionAboveCell
  }
  func positionForRow (row: Int, column: Int, nodeHeight: CGFloat) -> SCNVector3 {
    return (
      positionForRow(row, column: column) +
      SCNVector3(0, nodeHeight/2, 0)
    )
  }
  func positionForRow (row: Int, column: Int) -> SCNVector3 {
    let offsetX = -gridWidth/2 + SceneViewController.cellWidth/2 + SceneViewController.cellPadding/2
    let offsetZ = -gridLength/2 + SceneViewController.cellLength/2 + SceneViewController.cellPadding/2
    return SCNVector3(
      offsetX + CGFloat(column) * CGFloat(SceneViewController.cellWidth + SceneViewController.cellPadding),
      gridHeight/2 + SceneViewController.cellHeight,
      offsetZ + CGFloat(row) * CGFloat(SceneViewController.cellLength + SceneViewController.cellPadding)
    )
  }
}

// MARK: Action

extension SceneViewController {
  func find () {
    let cellsOnPath = grid.findPathFromTargetToSource() // .reverse()
    var previousRow: Int?
    var previousColumn: Int?
    var cellIndex = cellsOnPath.count - 2
    
    func iterate () {
      let cell = cellsOnPath[cellIndex]
      let actions = moveHeroToRow(cell.coordinate.row,
        column: cell.coordinate.column,
        previousRow: previousRow,
        previousColumn: previousColumn
      )
      previousRow = cell.coordinate.row
      previousColumn = cell.coordinate.column
      cellIndex -= 1
      
      let movementSequence = SCNAction.sequence(actions)
      heroNode.runAction(movementSequence) {
        if cellIndex >= 0 {
          if cell.kind == .Intelligence {
            self.heroNode.removeFromParentNode()
            self.heroActivePercentage += 1 / CGFloat(self.grid.calculateIntelligenceCount())
            
            let intelligence = self.gridNode.childNodeWithName("Intelligence=" + String(cell.coordinate.row) + "," + String(cell.coordinate.column), recursively: true)!
            intelligence.removeFromParentNode()
            
            self.createHeroPositionedAtRow(cell.coordinate.row, column: cell.coordinate.column)
          }
          iterate()
        }
      }
    }
    
    iterate()
  }
}
//
//  SceneViewController.swift
//  Emag
//
//  Created by Morgan Wilde on 13/02/2016.
//  Copyright © 2016 Morgan Wilde. All rights reserved.
//

import UIKit
import SceneKit

class SceneViewController: UIViewController {
  @IBOutlet weak var sceneView: SCNView!
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
    
    let scene = SCNScene()
    
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    camera.name = "WorldCamera"
    camera.zNear = 1.0
    camera.zFar = 100.0
    camera.xFov = 0
    camera.yFov = 0
    
    camera.usesOrthographicProjection = true
    camera.orthographicScale = 2
    
    cameraNode.camera = camera
    cameraNode.position = SCNVector3(0, 0, 100)
    
    scene.rootNode.addChildNode(cameraNode)
    
    let redColorMaterial = SCNMaterial()
    redColorMaterial.diffuse.contents = UIColor.blueColor()
    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    box.firstMaterial = redColorMaterial
    
    let boxNode = SCNNode(geometry: box)
    
    let angle = (60 / 180) * M_PI
    boxNode.eulerAngles = SCNVector3(angle, 0, 0)
    
    scene.rootNode.camera = camera
    
    scene.rootNode.addChildNode(boxNode)
    
    sceneView.scene = scene
  }
}

// MARK: View Controller settings

extension SceneViewController {
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
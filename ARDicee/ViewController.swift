//
//  ViewController.swift
//  ARDicee
//
//  Created by Yasin Cengiz on 4.10.2019.
//  Copyright © 2019 MrYC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DEBUG: Shows dots for plane detection
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    //MARK: DICE RENDERING METHODS
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first{
                //print(hitResult)
                addDice(atLocation: hitResult)
            }
        }
    }
    
    
    func addDice(atLocation location : ARHitTestResult) {
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x,
                                           y: location.worldTransform.columns.3.y,
                                           z: location.worldTransform.columns.3.z)
            //append the rolled number on dice to array
            diceArray.append(diceNode)
            
            // Adds dice to scene
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        }
        
    }
    
    
    //MARK: ROLL FUNCTIONS
    
    
    func roll(dice: SCNNode) {
        // ROTATING DICE  ---- rotating the dice on Y axis will not change the numbers
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5),
                               y: 0,
                               z: CGFloat(randomZ * 5),
                               duration: 0.5)
        )
    }
    
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
        
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    
    // Shake phone
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    // Remove all dices
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    
    
    //MARK: ARSCNViewDelegateMethods
    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)

        node.addChildNode(planeNode)
        
    }


    //MARK: Plane Rendering Methods
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {

//        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),
//                             height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        //make the plane horizontal (default is vertical)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2,
                                                     // In order to rotate clockwise add " - "
                                                     1,
                                                     0,
                                                     0)
        // Shows a grid on the detected surface (Uncomment -- let plane == as well)
        
//        let gridMaterial = SCNMaterial()
//        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//        plane.materials = [gridMaterial]
//        planeNode.geometry = plane

        return planeNode
    }






}



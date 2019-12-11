//
//  ViewController.swift
//  ARDicee
//
//  Created by Kevin Smith on 11/25/19.
//  Copyright © 2019 Kevin Smith. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] //throws a bunch of dots everywhere.
        //They are looking for feature points.
        //They aren't easy on reflective surfaces.
        //If there are not feature points
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let sphere = SCNSphere(radius: 0.2)
//
//        let material = SCNMaterial()
//
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//
//        sphere.materials = [material]
//
//        let node = SCNNode()
//
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        
        
//        // Create a new scene
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//        // 3d POsition for placing dice
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
//        //sets position
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//
//            sceneView.scene.rootNode.addChildNode(diceNode)
//        }
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    // Notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        // what is a session configuration?
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal // detects planes and triggers the renderer delegate method.
        

        print("ARWorldTracking = \(ARWorldTrackingConfiguration.isSupported)")
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    //gets called when there is a touch in the view or in the window
    //ARKit converts the touch param into a real world location
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //First checks if touches were detected. Making sure the method was not called by accident.
        
        if let touch = touches.first { //Touch.first is the first location that the users touches on the screen. multitouch is not enabled.
            //This method returns the current location of a UITouch object in the coordinate system of the specified view. Because the touch object might have been forwarded to a view from another view, this method performs any necessary conversion of the touch location to the coordinate system of the specified view.
            //The return object is a CGPoint
            let touchLocation = touch.location(in: sceneView) //Returns the location of the touch dete
            
            //Hit testing searches for real-world objects or surfaces detected through the AR session's processing of the camera image. A 2D point in the view's coordinate system can refer to any point along a 3D line that starts at the device camera and extends in a direction determined by the device orientation and camera projection. This method searches along that line, returning all objects that intersect it in order of distance from the camera.
            //HOW IT WORKS:
            // You are runnign a program on your screen and you tap a point on the screen. That triggers the touchesBegan method, looking for the location
            // of that touch.
            // The original touch location is a 2D spot on the phone screen.
            // Adds the Z component to make it 3D
            //RETURNS A list of results, sorted from nearest to farthest (in distance from the camera).
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            //This will tell us whether we touched an existing plane or not
//            if !results.isEmpty {
//                print("touched the plane")
//            } else {
//                print("touched somewhere else")
//            }
            
            if let hitResult = results.first { //tells whether the hit test reurned an array with at least one resut. 
                print(hitResult)
                
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                // 3d POsition for placing dice
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
                //sets position on the plane
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y +  (diceNode.boundingSphere.radius *  diceNode.scale.x),
                        z: hitResult.worldTransform.columns.3.z
                    )
                    
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)

                }
                //
                //        // Set the scene to the view
                //        sceneView.scene = scene
            }
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode){
         //Randomly selects 90, 180, 270, or 360 degrees
         let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
         
         let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
         
         //Rotates the 3D object.
         
         dice.runAction(SCNAction.rotateBy(
             x: CGFloat(randomX * 5),
             y: 0,
             z: CGFloat(randomZ * 5),
             duration: 0.5)
         )
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    //detects a horizontal surface and gives it a width and height
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //Checks to see if the detected anchor is a flat plane or not
        if anchor is ARPlaneAnchor{
            //print("plane detected")
            //Downcasts the the anchor as a plane anchor
            let planeAnchor = anchor as! ARPlaneAnchor //downcast to plane anchor. checks if anchor is plane
            
            //converts dimensions of plane anchor into scene plane
            //similar to creating sphere
            //At this point, you are only creating a digital plane. It has nowhere to be because positioning has not been assigned.
            //All that has been assigned is the width and the height of the plane itself
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            //Uses x and z. This SCNPlane object is the length and the width of the plane anchor that is detected by the renderer
            
            //A structural element of a scene graph, representing a position and transform in a 3D coordinate space, to which you can attach geometry,
            // lights, cameras, or other displayable content.
            //IN English - It's like a point in a 3D field where something goes. We'll eventually connect this to the plane that we created earlier.
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z) //Sets the position of the plane node
            
            //TRICKY: Planes have widths and heights, which, in this case are taken from the x and z measurements of the plane achor, however the the
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0) //The plane is inherently vertical, so this statement turns it over.
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
            
        } else {
            return
        }
    }

    

}

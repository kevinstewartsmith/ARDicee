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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
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

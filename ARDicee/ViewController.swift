//
//  ViewController.swift
//  ARDicee
//
//  Created by Шапагат on 5/19/20.
//  Copyright © 2020 Shapagat Bolat. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate{
    
    @IBOutlet var sceneView: ARSCNView!
    var mushroomArray:[SCNNode] = []
    
    
    //MARK:-LifeCycleMethods
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    //MARK:-MushroomMethods
    func rotateAll(){
        if !mushroomArray.isEmpty{
            for mush in mushroomArray{
                rotate(mush: mush)
            }
        }
    }
    func rotate(mush: SCNNode){
        mush.runAction(
            SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi*2), z: 0, duration: 1)
        )
    }
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        if !mushroomArray.isEmpty{
            for mush in mushroomArray{
                mush.removeFromParentNode()
            }
        }
    }
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        rotateAll()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rotateAll()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first{
                addMush(at: hitResult)
                
            }
        }
    }
    
    func addMush(at location: ARHitTestResult){
        let mushroomScene = SCNScene(named: "art.scnassets/Mushroom.scn")!
        if let mushroomNode = mushroomScene.rootNode.childNode(withName: "Mushroom", recursively: true){
            mushroomNode.position = SCNVector3(x:location.worldTransform.columns.3.x, y:location.worldTransform.columns.3.y, z:location.worldTransform.columns.3.z)
            rotate(mush: mushroomNode)
            mushroomArray.append(mushroomNode)
            sceneView.scene.rootNode.addChildNode(mushroomNode)
        }
    }
    
    //MARK:-ARSCNViewDelegateMethods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else{return}
        let planeNode = createPlane(with: planeAnchor)
        node.addChildNode(planeNode)
        
    }
    //MARK:-Plane Rendering Methods
    func createPlane(with anchor: ARPlaneAnchor)->SCNNode{
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [planeMaterial]
        planeNode.geometry = plane
        return planeNode
    }
    
    
}


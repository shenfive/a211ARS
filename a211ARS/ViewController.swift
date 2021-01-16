//
//  ViewController.swift
//  a211ARS
//
//  Created by 申潤五 on 2021/1/16.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planes:[OverlayPlane] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        
        sceneView.scene = scene
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01) //新增一個 BOX
//        let material = SCNMaterial() //新增材質
//        material.diffuse.contents = UIColor.red //材質內容為紅色
//        box.materials = [material] //把 box 的貼圖材質加進去
//        let node = SCNNode(geometry: box) //新增一個 Box
//        node.position = SCNVector3(0, 0, -0.5) //設定 node 在空間的位置
//        sceneView.scene.rootNode.addChildNode(node) //把 node 加入到目前的 scene 上
        
        
//        let text = SCNText(string: "Hello Text in AR", extrusionDepth: 1.0)
//        text.firstMaterial?.diffuse.contents = UIColor.blue
        
//        let textNode = SCNNode(geometry: text)
//        textNode.position = SCNVector3(0, 0.05, -0.5)
//        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
//        sceneView.scene.rootNode.addChildNode(textNode)
        
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(taped(sender:)))
        sceneView.addGestureRecognizer(gesture)
        
        
//        let earth = SCNSphere(radius: 0.3)
//        earth.firstMaterial?.diffuse.contents = UIImage(named: "worldmap")
//        let earthNode = SCNNode(geometry: earth)
//        earthNode.position = SCNVector3(0, 0, -1)
//        sceneView.scene.rootNode.addChildNode(earthNode)
        
        
        
        sceneView.scene = scene
        sceneView.debugOptions = [.showWorldOrigin]
    }
    
    
    @objc func taped(sender:UIGestureRecognizer){
        let view = sender.view as! ARSCNView
        //由傳送者取得 ARView 的實體, 必需為 ARSCNView 才能偵測 plane
        let location = sender.location(in: view)
        let hitResult = view.hitTest(location, types: .existingPlaneUsingExtent) //試試是否是點到 plane
        if let firstHitResults = hitResult.first{
            self.addSphere(hitResult: firstHitResults)
        }
        
        
        
        
//        let view = sender.view as! SCNView //由傳送者取得 ARView 的實體
//        let location = sender.location(in: view) //取得點選的畫面座標
//        let hitResult = view.hitTest(location, options: nil) //試試看能不能點到東西
//        if hitResult.isEmpty != true{
//            print("some thing!")
//            let randomColor = UIColor(
//                red: CGFloat(arc4random()) / CGFloat(UInt32.max),
//                green: CGFloat(arc4random()) / CGFloat(UInt32.max),
//                blue:  CGFloat(arc4random()) / CGFloat(UInt32.max),
//                alpha: 1.0)
//            hitResult[0].node.geometry?.materials[0].diffuse.contents = randomColor
//
//        }else{
//            print("nothing!")
//        }
    }
    @objc func addSphere(hitResult:ARHitTestResult){
        let sphere = SCNSphere(radius: 0.025)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "worldmap")
        sphere.materials = [material]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y+0.5, hitResult.worldTransform.columns.3.z)
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)//加上物理特性並啟動
        
 
        
        
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01) //新增一個 BOX
        let material2 = SCNMaterial() //新增材質
        material2.diffuse.contents = UIColor.red //材質內容為紅色
        box.materials = [material2] //把 box 的貼圖材質加進去
        let node = SCNNode(geometry: box) //新增一個 Box
        node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y+0.5, hitResult.worldTransform.columns.3.z) //設定 node 在空間的位置
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        
    }

    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("a plane")
        if !(anchor is ARPlaneAnchor) { return } //確定找到加入的是 plane
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor) //產出自訂義的可視平台
        self.planes.append(plane) //新增到 ViewController 的記錄中
        node.addChildNode(plane) //把自訂義的可視元件，蓋一層到平台上
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
        }.first?.update(anchor: anchor as! ARPlaneAnchor )
    
    }

    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

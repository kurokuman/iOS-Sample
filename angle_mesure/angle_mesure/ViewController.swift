//
//  ViewController.swift
//  mesure
//
//  Created by 黒澤知之 on 2018/10/28.
//  Copyright © 2018年 Tomoyuki Kurosawa. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var center : CGPoint!
    
    let abc : [String] = ["A","B","C"]
    
    var xyzNum : Int = 0
    let xyz : [String] = ["x", "y", "z", "xy"]
    
    let xyzAngle : [String] = ["xz","xy"]
    //distance:0 angle:1 status
    var MeasureState : Int = 0
    
    @IBOutlet var xyzchange: UIButton!
    
    // xyzのボタンラベルを変更，xyzNumをプラス１，もしくは0にして返す
    func xyzTextChange( xyzNum : Int, xyzText : [String]) -> Int{
        var NewxyzNum : Int = xyzNum
        if NewxyzNum == (xyzText.count - 1) {
            NewxyzNum = 0
        }
        else{
            NewxyzNum += 1
        }
        xyzchange.setTitle(xyzText[NewxyzNum], for: .normal)
        return NewxyzNum
    }
    
    
    @IBAction func xyzchange(_ sender: Any) {
        if MeasureState == 0{
            xyzNum =  xyzTextChange(xyzNum: xyzNum, xyzText: xyz)
        }
        else{
            xyzNum = xyzTextChange(xyzNum: xyzNum, xyzText: xyzAngle)
        }
        
        
    }


    
    
    
    let arrow = SCNScene(named: "art.scnassets/arrow.scn")!.rootNode
    
    var positions = [SCNVector3]()
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let hitTest = sceneView.hitTest(center, types: .featurePoint)
        let result = hitTest.last
        guard let transform = result?.worldTransform else { return }
        let thirdColumn = transform.columns.3
        let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        positions.append(position)
        let lastTenPositions = positions.suffix(10)
        arrow.position = getAveragePosition(from: lastTenPositions)
    }
    
    func getAveragePosition(from positions : ArraySlice<SCNVector3>) -> SCNVector3{
        var averageX : Float! = 0
        var averageY : Float! = 0
        var averageZ : Float! = 0
        
        for position in positions{
            averageX += position.x
            averageY += position.y
            averageZ += position.z
        }
        let count = Float(positions.count)
        return SCNVector3Make(averageX / count, averageY / count, averageZ / count)
    }
    
    //角度計算
    func angle(point1 : SCNVector3, point2 : SCNVector3, point3 : SCNVector3, xyzNum : Int) -> Float{
        let vec21x : Float = point2.x - point1.x
        let vec21y : Float = point2.y - point1.y
        let vec21z : Float = point2.z - point1.z
        let vec31x : Float = point3.x - point1.x
        let vec31y : Float = point3.y - point1.y
        let vec31z : Float = point3.z - point1.z
        
        var cosVolue : Float = 0
        
        if xyzNum == 0{
             cosVolue = (vec21x * vec31x + vec21z * vec31z)/(sqrt(pow(vec21x, 2) + pow(vec21z, 2)) * sqrt(pow(vec31x, 2) + pow(vec31z, 2)))
        }
        else{
             cosVolue = (vec21x * vec31x + vec21y * vec31y)/(sqrt(pow(vec21x, 2) + pow(vec21y, 2)) * sqrt(pow(vec31x, 2) + pow(vec31y, 2)))
        }
        var theta : Float = acos(cosVolue)
        
        theta = theta * 180 / Float(M_PI)
        
        return theta
    }
    
   
    
    var count : Int = 0
    var points = [SCNNode]()
    
    
    @IBOutlet var MeasureAngle: UIButton!
    
    
    // 計測切り替え

    @IBAction func measureAngleChange(_ sender: Any) {
        xyzNum = 0
        
        if MeasureState == 0 {
            MeasureAngle.setTitle("角度計測", for: .normal)
            xyzchange.setTitle(xyzAngle[xyzNum], for: .normal)
            MeasureState += 1
        }
        else if MeasureState == 1{
            MeasureAngle.setTitle("角度指定", for: .normal)
            xyzchange.setTitle(xyz[xyzNum], for: .normal)
            MeasureState = 2
        }
        else{
            MeasureAngle.setTitle("距離計測", for: .normal)
            xyzchange.setTitle(xyz[xyzNum], for: .normal)
            MeasureState = 0
        }
        
        //計測切り替え時にノードを削除
        if points.count >= 1 {
           self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
                node.removeFromParentNode()
                count = 0
            }
        }
    }
    
    //delete node
    @IBOutlet var delButton: UIButton!
    @IBAction func NodeDel(_ sender: Any) {
        if points.count >= 1 {
           self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
                node.removeFromParentNode()
                count = 0
            }
        }
        
    }
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    @IBAction func measure(_ sender: Any) {
        
        
        // 距離計測
        if MeasureState == 0{
            
            let sphereGeometry = SCNSphere(radius: 0.005)
            let sphereNode = SCNNode(geometry: sphereGeometry)
            
            sphereNode.position = arrow.position
            
            sceneView.scene.rootNode.addChildNode(sphereNode)
            points.append(sphereNode)
            
            
            if count == 0{
                count = 1
            }
            else{
                let pointA = points[points.count - 2]
                guard let pointB = points.last else {return}
                
                //            let d = distance(float3(pointA.position), float3(pointB.position))
                // fabs absのfloat
                let disX = abs(pointA.position.x - pointB.position.x)
                let disY = abs(pointA.position.y - pointB.position.y)
                let disZ = abs(pointA.position.z - pointB.position.z)
                let disXY = sqrtf(powf(pointA.position.x - pointB.position.x,2) + powf(pointA.position.x - pointB.position.x, 2))
                
                
                var dist : [Float] = [disX,
                                      disY,
                                      disZ,
                                      disXY]

                
                
                //add line
                let line = SCNGeometry.line(from: pointA.position, to: pointB.position)
                let lineNode = SCNNode(geometry: line)
                sceneView.scene.rootNode.addChildNode(lineNode)
                
                //中間点の追加
                let midPoint = (float3(pointA.position) + float3(pointB.position)) / 2
                let midPointGeometry = SCNSphere(radius: 0.003)
                midPointGeometry.firstMaterial?.diffuse.contents = UIColor.red
                let midPointNode = SCNNode(geometry: midPointGeometry)
                midPointNode.position = SCNVector3Make(midPoint.x, midPoint.y, midPoint.z)
                sceneView.scene.rootNode.addChildNode(midPointNode)
                
                //add text
                let textGeometry = SCNText(string: String(format:xyz[xyzNum] + ":" + "%.0f",dist[xyzNum] * 100) + "cm", extrusionDepth: 1)
                let textNode = SCNNode(geometry: textGeometry)
                textNode.scale = SCNVector3Make(0.005, 0.005, 0.01)
                textGeometry.flatness = 0.2
                midPointNode.addChildNode(textNode)
                
                
                //Billboard Contrains
                let contraints = SCNBillboardConstraint()
                contraints.freeAxes = .all
                midPointNode.constraints = [contraints]
                
                count  = 0
            }
            
        }
        
        //角度計測
        else if MeasureState == 1{
            
            let sphereGeometry = SCNSphere(radius: 0.005)
            let sphereNode = SCNNode(geometry: sphereGeometry)
            
            sphereNode.position = arrow.position
            
            sceneView.scene.rootNode.addChildNode(sphereNode)
            points.append(sphereNode)
        
        
            if count == 0{
                count = 1
            }
            else if count == 1{
                count = 2
            }
            else if count == 2{
                count = 0
                
                let pointA = points[points.count - 3]
                let pointB = points[points.count - 2]
                guard let pointC = points.last else {return}
                
                
                //add line
                let lineAB = SCNGeometry.line(from: pointA.position, to: pointB.position)
                let lineABNode = SCNNode(geometry: lineAB)
                sceneView.scene.rootNode.addChildNode(lineABNode)
                
                let lineBC = SCNGeometry.line(from: pointB.position, to: pointC.position)
                let lineBCNode = SCNNode(geometry: lineBC)
                sceneView.scene.rootNode.addChildNode(lineBCNode)
                
                let lineCA = SCNGeometry.line(from: pointC.position, to: pointA.position)
                let lineCANode = SCNNode(geometry: lineCA)
                sceneView.scene.rootNode.addChildNode(lineCANode)
                
                
                
                let thetaA : Float = angle(point1: pointA.position, point2: pointB.position, point3: pointC.position, xyzNum: xyzNum)
                let thetaB : Float = angle(point1: pointB.position, point2: pointC.position, point3: pointA.position, xyzNum: xyzNum)
                let thetaC : Float = angle(point1: pointC.position, point2: pointA.position, point3: pointB.position, xyzNum: xyzNum)
                
                let AtextGeometry = SCNText(string:"A" + String(format:"%.1f", thetaA ) + "°", extrusionDepth: 1)
                let AtextNode = SCNNode(geometry: AtextGeometry)
                AtextNode.scale = SCNVector3Make(0.002, 0.002, 0.005)
                AtextGeometry.flatness = 0.2
                pointA.addChildNode(AtextNode)
                
                
                let BtextGeometry = SCNText(string:"B" + String(format:"%.1f", thetaB ) + "°", extrusionDepth: 1)
                let BtextNode = SCNNode(geometry: BtextGeometry)
                BtextNode.scale = SCNVector3Make(0.002, 0.002, 0.005)
                BtextGeometry.flatness = 0.2
                pointB.addChildNode(BtextNode)
                
                
                let CtextGeometry = SCNText(string:"C" + String(format:"%.1f", thetaC ) + "°", extrusionDepth: 1)
                let CtextNode = SCNNode(geometry: CtextGeometry)
                CtextNode.scale = SCNVector3Make(0.002, 0.002, 0.005)
                CtextGeometry.flatness = 0.2
                pointC.addChildNode(CtextNode)
                
                //Billboard Contrains
                let contraintsA = SCNBillboardConstraint()
                contraintsA.freeAxes = .all
                pointA.constraints = [contraintsA]
                
                let contraintsB = SCNBillboardConstraint()
                contraintsB.freeAxes = .all
                pointB.constraints = [contraintsB]
                
                let contraintsC = SCNBillboardConstraint()
                contraintsC.freeAxes = .all
                pointC.constraints = [contraintsC]
            
            
                }
        }
        else{
            
            
            let AGeometry = SCNSphere(radius: 0.01)
            let ANode = SCNNode(geometry: AGeometry)
            
            ANode.position = SCNVector3(0,0,-0.2)
            
            let BGeometry = SCNSphere(radius: 0.01)
            let BNode = SCNNode(geometry: BGeometry)
            
            BNode.position = SCNVector3(0,0,-1.2)
            
            let CGeometry = SCNSphere(radius: 0.01)
            let CNode = SCNNode(geometry: CGeometry)
            
            let wantTheta : Float = 30
            let theta : Float = 90 - wantTheta
            
            CNode.position = SCNVector3(-cos(theta),0,-sin(theta) - 0.2)
            
            sceneView.scene.rootNode.addChildNode(ANode)
            sceneView.scene.rootNode.addChildNode(BNode)
            sceneView.scene.rootNode.addChildNode(CNode)
            
            let ABline = SCNGeometry.line(from: ANode.position, to: BNode.position)
            let ABLineNode = SCNNode(geometry: ABline)
            sceneView.scene.rootNode.addChildNode(ABLineNode)
            
            let ACline = SCNGeometry.line(from: ANode.position, to: CNode.position)
            let ACLineNode = SCNNode(geometry: ACline)
            sceneView.scene.rootNode.addChildNode(ACLineNode)
            
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        center = view.center
        //sceneView.scene.rootNode.addChildNode(arrow)
        sceneView.autoenablesDefaultLighting = true
        
    }
    

    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        center = view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

}




extension SCNGeometry{
    
    class func line(from vectorA : SCNVector3, to vectorB : SCNVector3) -> SCNGeometry{
        let indices : [Int32] = [0,1]
        let source = SCNGeometrySource(vertices: [vectorA,vectorB])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return  SCNGeometry(sources: [source], elements: [element])
    }
    
}

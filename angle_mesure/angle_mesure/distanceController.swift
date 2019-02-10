//
//  distanceController.swift
//  angle_mesure
//
//  Created by 黒澤知之 on 2018/10/31.
//  Copyright © 2018年 Tomoyuki Kurosawa. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class distanceController: UIViewController,ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var center : CGPoint!
    
    let abc : [String] = ["A","B","C"]
    
    
    let arrow = SCNScene(named: "art.scnassets/arrow.scn")!.rootNode
    
    var positions = [SCNVector3]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        center = view.center
        sceneView.scene.rootNode.addChildNode(arrow)
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

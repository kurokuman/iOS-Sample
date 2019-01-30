//
//  ViewController.swift
//  motionSensor
//
//  Created by kurokuman on 2019/01/30.
//  Copyright © 2019年 kurokuman. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    
    @IBOutlet var gollira: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let originalX = gollira.center.x
        let originalY = gollira.center.y
        
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion,error) in
                print(motion!.attitude.roll)
                let newX = originalX + CGFloat(motion!.attitude.roll * 150)
                let newY = originalY + CGFloat(motion!.attitude.pitch * 200)
                
                self.gollira.center = CGPoint(x: newX, y: newY)
            })
        }
        
    }
    
    
    
    //モーションセンサーを止める
//    func stopSensor(){
//        motionManager.stopDeviceMotionUpdates()
//    }


}


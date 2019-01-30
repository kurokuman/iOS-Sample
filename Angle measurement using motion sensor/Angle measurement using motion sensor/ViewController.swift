//
//  ViewController.swift
//  Angle measurement using motion sensor
//
//  Created by kurokuman on 2019/01/31.
//  Copyright © 2019年 kurokuman. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    
    @IBOutlet var MeasureButton: UIButton!
    
    var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func Measure(_ sender: Any) {
        if flag == 0{
            flag = 1
            MeasureButton.setTitle("STOP", for: .normal)
            
            if motionManager.isDeviceMotionAvailable{
                motionManager.deviceMotionUpdateInterval = 0.5
                motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion,error) in
                    print("X : ",motion!.attitude.roll)
                    print("Y : ",motion!.attitude.pitch)
                    print("Z : ",motion!.attitude.yaw)
                    
                    //°に変換
                    var angleX = motion!.attitude.roll * 180.0 / M_PI
                    var angleY = motion!.attitude.pitch * 180.0 / M_PI
                    var angleZ = motion!.attitude.yaw * 180.0 / M_PI
                    
                    //小数点以下3位で切り捨てて表示
                    self.xLabel.text = "X : \(floor(angleX*100)/100)°"
                    self.yLabel.text = "Y : \(floor(angleY*100)/100)°"
                    self.zLabel.text = "Z : \(floor(angleZ*100)/100)°"
                    
                })
            }//if motionManager
        }else{
            flag = 0
            MeasureButton.setTitle("START", for: .normal)
            //モーションセンサーストップ
            motionManager.stopDeviceMotionUpdates()
        }
        
    }//func
    
}

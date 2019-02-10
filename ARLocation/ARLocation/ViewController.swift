//
//  ViewController.swift
//  ARLocation
//
//  Created by kurokuman on 2018/12/05.
//  Copyright © 2018年 kurokuman. All rights reserved.
//


//現在地の緯度経度を取得するプログラム
// Info.plist   Privacy - Location When In Use U・・・

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapKit



class ViewController: UIViewController, ARSCNViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var ido: UILabel!
    @IBOutlet var keido: UILabel!
    @IBOutlet var hougaku: UILabel!
    @IBOutlet var muki: UILabel!
    
    @IBOutlet var docchi: UILabel!
    
    var targetAddress : String = ""
    
    @IBOutlet var inputAddress: UITextField!
    
    var x2 : CGFloat = 0.1
    var y2 : CGFloat = 0.1
    var houi : Int = 0
    
    var count : Int = 0
    
    var node : SCNNode? = nil
    var ARnode: SCNNode? = nil
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        inputAddress.delegate = self

        
    }
    

    @IBAction func putText(_ sender: Any) {
        
        let At : String = "↑"
        let text = SCNText(string: At, extrusionDepth: 1)
        let node = SCNNode()
        node.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        node.geometry = text
        ARnode = node

        sceneView.scene.rootNode.addChildNode(node)
        
        
        targetAddress = inputAddress.text!
        geocode(address: targetAddress)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()      // 方角
    }
    
    //画面のどこかをタップしたらテキストフィールドを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            inputAddress.resignFirstResponder()
    }
    
    //テキスト入力後returnを押したらテキストフィールドを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputAddress.resignFirstResponder()
        return true
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
        setupLocationManager()
        
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    //位置情報の許可
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    //住所を緯度経度に変換
    func geocode(address:String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) -> Void in
            for placeMark in placemarks! {
                  self.x2 = CGFloat(placeMark.location!.coordinate.latitude)
                  self.y2 = CGFloat(placeMark.location!.coordinate.longitude)
                }
            }
    }

    
    //自分の経度緯度を取得
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else {
            return
        }

        
        var x1 = CGFloat(newLocation.coordinate.latitude)
        var y1 = CGFloat(newLocation.coordinate.longitude)
        
//        print("緯度:".appendingFormat("%f",x1))
//        print("経度:".appendingFormat("%f",y1))
        
        
        ido.text = String(Float(x1))
        keido.text = String(Float(y1))
        
        //ターゲットまでの距離を取得
        var currentLocation: CLLocation = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        var oldLocation: CLLocation = CLLocation(latitude: CLLocationDegrees(x2), longitude: CLLocationDegrees(y2))
        var distance = Float(oldLocation.distance(from: currentLocation))
        
        print(distance)
        print(x2,y2)
        
        var theta = Int(angle(x1: x1, y1: y1, x2: x2, y2: y2))
        var gosa = Int(theta - houi)
        
        muki.text = String(gosa)
        print("theta",theta)
        //回転
        routine(theta: theta, houi: houi, distance: distance)
    }
    
    //どっちの方向を向けばいいか指示
    func routine(theta : Int , houi : Int, distance : Float){
        let Range : Int = 10
        
        var range180 : Int = theta + 180
        if range180 > 360{
            range180 -= 360
        }
        
        //ターゲットの位置が180以上か以下かで条件分岐
        if theta < 180{
            if (theta - Range < houi && houi < theta + Range){
                docchi.text  = "そのまま"
                ARnode?.scale = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
                ARnode?.geometry = SCNText(string: "Go\n" + String(Int(distance)) + "m", extrusionDepth: 1)
            }else if theta + Range...range180 ~= houi{
                docchi.text = "もっと左"
                ARnode?.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
                ARnode?.geometry = SCNText(string: "←", extrusionDepth: 1)
            }else{
                docchi.text = "もっと右"
                ARnode?.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
                ARnode?.geometry = SCNText(string: "→", extrusionDepth: 1)
            }
        }
        else{
            if (theta - Range < houi && houi < theta + Range){
                docchi.text  = "そのまま"
                ARnode?.scale = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
                ARnode?.geometry = SCNText(string: "Go\n" + String(Int(distance)) + "m", extrusionDepth: 1)
            }else if range180...theta - Range ~= houi{
                docchi.text = "もっと右"
                ARnode?.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
                ARnode?.geometry = SCNText(string: "→", extrusionDepth: 1)
            }else{
                docchi.text = "もっと左"
                ARnode?.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
                ARnode?.geometry = SCNText(string: "←", extrusionDepth: 1)
            }
        }
    }
    
    //オブジェクト移動・回転
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //カメラ位置にオブジェクトを追従
        guard let camera = sceneView.pointOfView else { return }
        let position = SCNVector3(x: -0.05, y: 0, z: -0.5)
        ARnode?.position = camera.convertPosition(position, to: nil)
        
        //オブジェクトが常にカメラを向くように回転
        if let camera = sceneView.pointOfView { // カメラを取得
            ARnode?.position = camera.convertPosition(position, to: nil)
            ARnode?.eulerAngles = camera.eulerAngles
        }
    }
    
    //自分の向いている方向を取得 北0度
    func locationManager(_ manager:CLLocationManager,didUpdateHeading newHeading:CLHeading) {
        //print("方角:".appendingFormat("%.2f",newHeading.magneticHeading))
        houi = Int(newHeading.magneticHeading)
        hougaku.text = String(houi)
    }

    
    //方位角計算 北0度
    func angle(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat{
        
        let x1 = x1 * (CGFloat.pi / 180)
        let y1 = y1 * (CGFloat.pi / 180)
        let x2 = x2 * (CGFloat.pi / 180)
        let y2 = y2 * (CGFloat.pi / 180)
        
        let difY = y2 - y1
        let y = sin(difY)
        let x = cos(x1) * tan(x2) - sin(x1) * cos(difY)
        let p = atan2(y, x) * 180 / CGFloat.pi
        
        if p < 0 {
            return CGFloat(360 + atan2(y, x) * 180 / CGFloat.pi)
        }
        return CGFloat(atan2(y, x) * 180 / CGFloat.pi)
    }
    
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
    
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
}


//
//  MapViewController.swift
//  Geocording
//
//  Created by kurokuman on 2019/02/01.
//  Copyright © 2019年 kurokuman. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var address = ""
    @IBOutlet var mapView:  MKMapView!
    @IBOutlet var latLabel: UILabel!
    @IBOutlet var lngLabel: UILabel!
    
    var lat : CLLocationDegrees = 0.1
    var lng : CLLocationDegrees = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var region = MKCoordinateRegion()
        
        //住所を緯度経度に変換
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) -> Void in
            for placeMark in placemarks! {
                //緯度経度取得
                self.lat = placeMark.location!.coordinate.latitude
                self.lng = placeMark.location!.coordinate.longitude
                
                //緯度経度の場所を表示
                region.center = CLLocationCoordinate2DMake(self.lat, self.lng)
                region.span.latitudeDelta = 0.01
                region.span.longitudeDelta = 0.01
                self.mapView.setRegion(region, animated: false)
                
                //Pinを立てる
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lng)
                self.mapView.addAnnotation(annotation)
                
                
                //ラベル変更
                self.latLabel.text = "緯度: \(self.lat)"
                self.lngLabel.text = "経度: \(self.lng)"
                
                print(self.lat)
                print(self.lng)
                
                }//for
            }
    }//viewDidloaded
    
}

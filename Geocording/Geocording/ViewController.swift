//
//  ViewController.swift
//  Geocording
//
//  Created by kurokuman on 2019/02/01.
//  Copyright © 2019年 kurokuman. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet var addressText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addressText.delegate = self
    }
    
    //return を押したらキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressText.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapVC = segue.destination as? MapViewController{
            mapVC.address = addressText.text!
        }
    }
    
    


}


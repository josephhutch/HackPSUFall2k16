//
//  InitViewController.swift
//  TESTIBMSPEECH
//
//  Created by Artemiy Galkin on 11/12/16.
//  Copyright © 2016 Artemiy Galkin. All rights reserved.
//

import Foundation

import UIKit
import HealthKit

class InitViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if HKHealthStore.isHealthDataAvailable() {
            
            //Initialize HKHealthStore
            let healthStore = HKHealthStore()
            
            if healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!) == HKAuthorizationStatus.sharingAuthorized {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goto_mainstart", sender: self)
                }
                print("Sharing Authorized.")
            }else{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goto_accessstart", sender: self)
                }
                print("The app is not authorized for sharing.")
            }
            
        }else{
            
            let alertController = UIAlertController(title: "Error", message: "Sorry, your device doesn't support HealthKit.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

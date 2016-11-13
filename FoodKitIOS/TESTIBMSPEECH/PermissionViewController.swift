//
//  ViewController.swift
//  TESTIBMSPEECH
//
//  Created by Artemiy Galkin on 11/12/16.
//  Copyright © 2016 Artemiy Galkin. All rights reserved.
//

import UIKit
import HealthKit

class PermissionViewController: UIViewController {

    @IBOutlet var permissionBtn: UIButton!
    var healthStore: HKHealthStore?
    
    @IBAction func permissionBtnPressed(_ sender: AnyObject) {
        
        if HKHealthStore.isHealthDataAvailable() {
            
            //Initialize HKHealthStore
            healthStore = HKHealthStore()
            
            //Set the types we want to read from HK Store
            let healthKitTypesToRead: Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)!]
            
            //Set the types we want to write to HK Store
            let healthKitTypesToWrite: Set<HKSampleType> = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)!]
            
            
            //Request HealthKit authorization
            healthStore?.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead, completion: { (success: Bool, error: Error?) in
                if error != nil{
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    if self.healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!) == HKAuthorizationStatus.sharingAuthorized {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "goto_mainaccess", sender: self)
                        }
                    }else{
                        let alertController = UIAlertController(title: "Error", message: "We need more data. Please go to Health app and give us all we want.", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    print("Authorization completed!")
                }
            })
            
            
        }else{
            print("HealthKit is not available on this device")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.permissionBtn.layer.cornerRadius = 5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


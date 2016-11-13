//
//  ConfirmProductViewController.swift
//  TESTIBMSPEECH
//
//  Created by Artemiy Galkin on 11/13/16.
//  Copyright © 2016 Artemiy Galkin. All rights reserved.
//

import UIKit
import HealthKit
import VisualRecognitionV3
import RestKit
import FirebaseStorage

class ConfirmProductViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var totalFatLabel: UILabel!
    @IBOutlet weak var totalCholestrolLabel: UILabel!
    @IBOutlet weak var totalSodiumLabel: UILabel!
    @IBOutlet weak var totalCarbohydratesLabel: UILabel!
    @IBOutlet weak var totalProteinLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var image: UIImage?
    var currentDay: String!
    
    var healthStore: HKHealthStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmBtn.layer.cornerRadius = 5
        self.cancelBtn.layer.cornerRadius = 5
        
        self.imageView.image = self.image
        
        self.resizeImage(image: self.image!, targetSize: CGSize(width: 500, height: 300))
        
        self.sendImageToServer(image: self.image)
        
    }
    
    func sendImageToServer(image: UIImage?){
        
        
        let myUrl = NSURL(string: "http://p405408.for-test-only.ru/picSaver.php")
        
        let request = NSMutableURLRequest(url: myUrl as! URL);
        request.httpMethod = "POST"
        
        var param: [String:String] = [:]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.8)
        
        if(imageData == nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: UIImageJPEGRepresentation(image!, 0.2)! as NSData, boundary: boundary) as Data
        
        //myActivityIndicator.startAnimating();
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    
                    let apiKey = "648cff685768fe2ce2c076a2290d104ceff3e6d7"
                    let version = "2016-11-13" // use today's date for the most recent version
                    let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
                    
                    let url = "http://p405408.for-test-only.ru/images/\(self.filename)"
                    let failure = { (error: Error) in print(error) }
                    visualRecognition.classify(image: url, failure: failure) { classifiedImages in
                        
                        if let classification = classifiedImages.images.first?.classifiers.first?.classes.first {
                            
                            DispatchQueue.main.async {
                                self.productNameLabel.text = classification.classification
                            }
                            
                            let link = "https://api.nutritionix.com/v1_1/search/\((classification.classification).replace(target: " ", withString: "%20"))?fields=item_name%2Cnf_calories%2Cnf_total_fat%2Cnf_cholesterol%2Cnf_sodium%2Cnf_total_carbohydrate%2Cnf_protein&appId=0ade1c44&appKey=627c35258c036c37885553d8714be8e4"
                            
                            let url = URL(string: link)
                            
                            
                            
                            
                            let task1 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                                guard error == nil && data != nil else {                                                          // check for fundamental networking error
                                    print("error=\(error)")
                                    return
                                }
                                
                                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                                    print("response = \(response)")
                                }
                                
                                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
                                
                                
                                if (responseString != "") {
                                    print("RESPONSE: \(responseString)")
                                    print("\n\n\n\n\n")
                                    do {
                                        
                                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSMutableDictionary
                                        
                                        if let parseJSON = json {
                                            
                                            print(parseJSON)
                                            //var arrr = parseJSON[0]
                                            let hits = parseJSON["hits"] as! NSArray
                                            let hit = hits.firstObject as! NSDictionary
                                            let hitInfo = hit["fields"] as! NSDictionary
                                            print("\n\n\n")
                                            print(hits)
                                            print(hit)
                                            print(hitInfo)
                                            
                                        }else{
                                            print("lol")
                                        }
                                    }catch{
                                        print("Ooops")
                                    }
                                }
                            }
                            
                            task1.resume()
                            
                        }else{
                            DispatchQueue.main.async {
                                self.productNameLabel.text = "Try again..."
                            }
                        }
                        
                    }
                    
                } else {
                    print("Oooopsss..")
                    DispatchQueue.main.async {
                        self.productNameLabel.text = "Try again..."
                    }
                }
        })
        
        
        
        task.resume()
        
        
    }
    
    var filename = ""
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        filename = "user\(arc4random_uniform(1000)).jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    

    func generateBoundaryString() -> String {
        
        return "Boundary-\(NSUUID().uuidString)"    
    }
    
    func saveImageToFile(image: UIImage) {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let filePath = "\(paths[0])/MyImageName.jpg"
        
        do {
            try UIImageJPEGRepresentation(image, 0.2)?.write(to: URL(fileURLWithPath: filePath), options: [])
        }catch{
            print("OOOppps... Didn't save the image")
        }
        
    }
    
    func imageFileURL() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let url = "\(paths[0])/MyImageName.jpg"
        return "\(url)"
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func confirmBtnPressed(_ sender: AnyObject) {
        
        let name = self.productNameLabel.text!
        let fat = Double(self.totalFatLabel.text!)!
        let cholesterol = Double(self.totalCholestrolLabel.text!)!
        let sodium = Double(totalSodiumLabel.text!)!
        let carbs = Double(self.totalCarbohydratesLabel.text!)!
        let protein = Double(self.totalProteinLabel.text!)!
        
        let newProduct = Product(name: name, totalFat: fat, totalCholesterol: cholesterol, totalSodium: sodium, totalCarbohydrate: carbs, totalProtein: protein)
        
        if HKHealthStore.isHealthDataAvailable() {
            
            //Initialize HKHealthStore
            healthStore = HKHealthStore()
            
            if self.healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!) == HKAuthorizationStatus.sharingAuthorized {
                
                let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)!
                let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: 100)
                let sample = HKQuantitySample(type: type, quantity: quantity, start: NSDate() as Date, end: NSDate() as Date)
                
                self.healthStore?.save(sample, withCompletion: { (success, error) in
                    if (error != nil) {
                        print("Error saving FAT sample: \(error?.localizedDescription)")
                    } else {
                        print("FAT sample saved successfully!")
                    }
                })
            }

            if self.healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol)!) == HKAuthorizationStatus.sharingAuthorized {
                
                let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol)!
                let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: 100 / 1000)
                let sample = HKQuantitySample(type: type, quantity: quantity, start: NSDate() as Date, end: NSDate() as Date)
                
                self.healthStore?.save(sample, withCompletion: { (success, error) in
                    if (error != nil) {
                        print("Error saving Cholesterol sample: \(error?.localizedDescription)")
                    } else {
                        print("Cholesterol sample saved successfully!")
                    }
                })
            }

            if self.healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)!) == HKAuthorizationStatus.sharingAuthorized {
                
                let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)!
                let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: 100 / 1000)
                let sample = HKQuantitySample(type: type, quantity: quantity, start: NSDate() as Date, end: NSDate() as Date)
                
                self.healthStore?.save(sample, withCompletion: { (success, error) in
                    if (error != nil) {
                        print("Error saving Sodium sample: \(error?.localizedDescription)")
                    } else {
                        print("Sodium sample saved successfully!")
                    }
                })
            }

            if self.healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)!) == HKAuthorizationStatus.sharingAuthorized {
                
                let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)!
                let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: 100)
                let sample = HKQuantitySample(type: type, quantity: quantity, start: NSDate() as Date, end: NSDate() as Date)
                
                self.healthStore?.save(sample, withCompletion: { (success, error) in
                    if (error != nil) {
                        print("Error saving Carbohydrates sample: \(error?.localizedDescription)")
                    } else {
                        print("Carbohydrates sample saved successfully!")
                    }
                })
            }

            if self.healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)!) == HKAuthorizationStatus.sharingAuthorized {
                
                let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)!
                let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: 100)
                let sample = HKQuantitySample(type: type, quantity: quantity, start: NSDate() as Date, end: NSDate() as Date)
                
                self.healthStore?.save(sample, withCompletion: { (success, error) in
                    if (error != nil) {
                        print("Error saving Protein sample: \(error?.localizedDescription)")
                    } else {
                        print("Protein sample saved successfully!")
                    }
                })
            }

            
        }
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let path = paths.appendingPathComponent("UserData.plist")
        let data = NSMutableDictionary(contentsOfFile: path)
        
        let history = data?.value(forKey: "History") as! NSMutableDictionary

        if let products = history.object(forKey: currentDay) {
            
            var allProducts: [Product] = []
            
            if let tempArr: [Product] = NSKeyedUnarchiver.unarchiveObject(with: products as! Data) as? [Product] {
                allProducts = tempArr
            }
            allProducts.append(newProduct)
            
            let superArray = NSKeyedArchiver.archivedData(withRootObject: allProducts)
            
            history.setObject(superArray, forKey: currentDay as NSCopying)
            data?.setValue(history, forKey: "History")
            data?.write(toFile: path, atomically: true)
            
        }else{
            let superArray = NSKeyedArchiver.archivedData(withRootObject: [newProduct])
            history.setObject(superArray, forKey: currentDay as NSCopying)
            data?.setValue(history, forKey: "History")
            data?.write(toFile: path, atomically: true)
        }
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Ooops...", message: "Something went wrong. Try again.", preferredStyle: .alert)
        
        let photoLibrary = UIAlertAction(title: "Retake the image", style: .default) { (action: UIAlertAction) in
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }
        
        let camera = UIAlertAction(title: "Type in the product", style: .default) { (action: UIAlertAction) in
            
            let alert = UIAlertController(title: "Product name", message: "Type in the product name.", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.text = ""
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                let textField = alert.textFields![0]
                self.productNameLabel.text = textField.text
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            
            _ = self.navigationController?.popToRootViewController(animated: true)
            
        }

        
        alertController.addAction(photoLibrary)
        alertController.addAction(camera)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

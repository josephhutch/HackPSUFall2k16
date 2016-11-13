//
//  TodayViewController.swift
//  TESTIBMSPEECH
//
//  Created by Artemiy Galkin on 11/12/16.
//  Copyright © 2016 Artemiy Galkin. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class TodayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var products: [Product] = []
    var currentDay: String!
//        [Product(name: "Apple", totalFat: 1, totalCholesterol: 2, totalSodium: 3, totalCarbohydrate: 4, totalProtein: 5),
//                    Product(name: "Pretzel", totalFat: 4, totalCholesterol: 3, totalSodium: 2, totalCarbohydrate: 1, totalProtein: 0),
//                    Product(name: "Snack", totalFat: 1, totalCholesterol: 1, totalSodium: 1, totalCarbohydrate: 1, totalProtein: 1)]
//    
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height / 12
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ProductDescriptionCell
        
        cell.nameLabel.text = products[indexPath.row].name!
        cell.totalFatLabel.text = "Fat: \(products[indexPath.row].totalFat!)g"
        cell.totalCarbohydratesLabel.text = "Carbs: \(products[indexPath.row].totalCarbohydrate!)g"
        cell.totalProteinLabel.text = "Protein: \(products[indexPath.row].totalProtein!)g"
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: date as Date)
        let month = calendar.component(.month, from: date as Date)
        let day = calendar.component(.day, from: date as Date)
        
        self.currentDay = "\(year)\(month)\(day)"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let path = paths.appendingPathComponent("UserData.plist")
        let data = NSMutableDictionary(contentsOfFile: path)
        
        let history = data?.value(forKey: "History") as! NSMutableDictionary
        
        if let products = history.object(forKey: currentDay) {

            if let tempArr: [Product] = NSKeyedUnarchiver.unarchiveObject(with: products as! Data) as? [Product] {
                self.products = tempArr
            }
            
        }else{
            
            let superArray = NSKeyedArchiver.archivedData(withRootObject: [])

            history.setObject(superArray, forKey: currentDay as NSCopying)
            data?.setValue(history, forKey: "History")
            data?.write(toFile: path, atomically: true)
            
        }
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goto_addmain"){
            let secondViewController = segue.destination as! AddProductViewController
            secondViewController.currentDay = self.currentDay
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

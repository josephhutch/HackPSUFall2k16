//
//  Product.swift
//  TESTIBMSPEECH
//
//  Created by Artemiy Galkin on 11/12/16.
//  Copyright © 2016 Artemiy Galkin. All rights reserved.
//

import Foundation

class Product: NSObject, NSCoding {
    
    var name: String!
    var totalFat: Double!
    var totalCholesterol: Double!
    var totalSodium: Double!
    var totalCarbohydrate: Double!
    var totalProtein: Double!
    
    init(name: String = "Default Name", totalFat: Double = 0, totalCholesterol: Double = 0,
         totalSodium: Double = 0, totalCarbohydrate: Double = 0, totalProtein: Double = 0){
        self.name = name
        self.totalFat = totalFat
        self.totalCholesterol = totalCholesterol
        self.totalSodium = totalSodium
        self.totalCarbohydrate = totalCarbohydrate
        self.totalProtein = totalProtein
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey:"name")
        aCoder.encode(self.totalFat, forKey:"totalFat")
        aCoder.encode(self.totalCholesterol, forKey:"totalCholesterol")
        aCoder.encode(self.totalSodium, forKey:"totalSodium")
        aCoder.encode(self.totalCarbohydrate, forKey:"totalCarbohydrate")
        aCoder.encode(self.totalProtein, forKey:"totalProtein")
    }
    
    required init (coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.totalFat = aDecoder.decodeObject(forKey: "totalFat") as! Double
        self.totalCholesterol = aDecoder.decodeObject(forKey: "totalCholesterol") as! Double
        self.totalSodium = aDecoder.decodeObject(forKey: "totalSodium") as! Double
        self.totalCarbohydrate = aDecoder.decodeObject(forKey: "totalCarbohydrate") as! Double
        self.totalProtein = aDecoder.decodeObject(forKey: "totalProtein") as! Double
    }
    
}

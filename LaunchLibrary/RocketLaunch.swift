//
//  RocketLaunch.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

class RocketLaunch : NSObject, NSCoding {
    
    var id : Int?
    var name : String?
    var date : String? // (net) - sorted ascending (default), should convert to Date
    var status : String? 
    var launchWindow : Array<Any>?
    var launchFrom : String? // Location
    var whereToWatch : String? // URL
    var rocket : Rocket? // Details about rocket (inc image...)
    var isSaved: Bool = false
    
    // Not designated
    convenience init (id : Int, name : String, status : String, date : String, launchWindow : Array<Any>, launchFrom : String, whereToWatch : String, rocket : Rocket) {
        self.init()
        self.id = id
        self.name = name
        self.status = status
        self.date = date
        self.launchWindow = launchWindow
        self.launchFrom = launchFrom
        self.whereToWatch = whereToWatch
        self.rocket = rocket
    }
    
    // MARK: NSCoding - Used to archive custom class (object) to NSData for storage
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        guard   let name = aDecoder.decodeObject(forKey: "name") as? String,
                let status = aDecoder.decodeObject(forKey: "status") as? String,
                let date = aDecoder.decodeObject(forKey: "date") as? String,
                let launchWindow = aDecoder.decodeObject(forKey: "launchWindow") as? Array<Any>,
                let launchFrom = aDecoder.decodeObject(forKey: "launchFrom") as? String,
                let whereToWatch = aDecoder.decodeObject(forKey: "whereToWatch") as? String,
                let rocket = aDecoder.decodeObject(forKey: "rocket") as? Rocket
        else { return nil }
        
        // Create object
        self.init(id: id, name: name, status: status, date: date, launchWindow: launchWindow, launchFrom: launchFrom, whereToWatch: whereToWatch, rocket: rocket)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(launchWindow, forKey: "launchWindow")
        aCoder.encode(launchFrom, forKey: "launchFrom")
        aCoder.encode(whereToWatch, forKey: "whereToWatch")
        aCoder.encode(rocket, forKey: "rocket")
    }
}


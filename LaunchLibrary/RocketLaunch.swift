//
//  RocketLaunch.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

class RocketLaunch : NSObject {
    
    var id : Int
    var name : String
    var date : String // (net) - sorted ascending (default), should convert to Date
    var status : Bool
    var launchWindow : Array<Any>
    var launchFrom : String // Location
    var whereToWatch : String // URL
    var rocket : Rocket! // Details about rocket (inc image...)
    
    
    init (id : Int, name : String, status : Bool, date : String, launchWindow : Array<Any>, launchFrom : String, whereToWatch : String, rocket : Rocket) {
        self.id = id
        self.name = name
        self.status = status
        self.date = date
        self.launchWindow = launchWindow
        self.launchFrom = launchFrom
        self.whereToWatch = whereToWatch
        self.rocket = rocket
    }
}

// TODO: Include NSCoding to archive data as NSData

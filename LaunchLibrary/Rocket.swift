//
//  Rocket.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 24/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

class Rocket : NSObject {
    
    var id : Int
    var name : String
    var agencies : Array<[String:AnyObject]>
    var imageString : String
    
    init (id : Int, name : String, agencies : Array<[String:AnyObject]>, imageString : String) {
        self.id = id
        self.name = name
        self.agencies = agencies
        self.imageString = imageString
        
    }
    
}

//
//  RocketLaunches.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Foundation

class RocketLaunches: NSObject {
    
    var collection: [RocketLaunch]? {
        didSet {
            // Add listeners ???
        }
    }
    
//    override init() {
//        super.init()
//        NetworkService.sharedInstance.fetchRocketLaunches(amount: amount, completionHandler: { (rocketLaunches) in
//            // TODO: Should be weak reference to self in this completion handler...
//            
//            // Using KVO for collection
//            self.collection = rocketLaunches
//        })
//    }
    
}

//
//  LaunchLibraryAPIHandler.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 09/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Foundation

class LaunchLibraryAPIHandler: NSObject {
    
    func handleLaunchLibraryData(launches: [[String: AnyObject]], completion: @escaping (_ results: [RocketLaunch]?, _ error: NSError?) -> Void) {
        
        // Ensure JSON is not empty
        //guard launches.values.flatten().isEmpty else { return }
        
        // Create temp launch library
        var launchLibrary = [RocketLaunch]()
        
        // Iterate over all launches recieved
        for launch in launches {
            
            // Safely unwrap launch properties required for collection
            guard let id = launch["id"] as? Int,
                let name = launch["name"] as? String,
                let net = launch["net"] as? String, // (formatted as Month, dd, yyyy hh24:mi:ss UTC)
                let status = launch["status"] as? Int, // Integer (1 Green, 2 Red, 3 Success, 4 Failed)
                let windowstart = launch["windowstart"] as? String,
                let windowend = launch["windowend"] as? String
                else {
                    let APIHandlerError = NSError(domain: Config.domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process launch \(launch["id"]!)"])
                    print(APIHandlerError)
                    print(launch)
                    continue
            }
            
            
            // January 25, 2018 05:51:00 UTC
            
            // Guard date formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Config.isoDate
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            guard let date = dateFormatter.date(from: net) else {
                // Problem formatting date
                print("Error: LaunchLibraryAPIHandler.handleLaunchLibraryData() -> Unable to format date \(net)")
                break
            }

            guard let startDate = dateFormatter.date(from: windowstart) else {
                // Problem formatting date
                print("Error: LaunchLibraryAPIHandler.handleLaunchLibraryData() -> Unable to format startDate \(windowstart)")
                break
            }

            guard let endDate = dateFormatter.date(from: windowend) else {
                // Problem formatting date
                print("Error: LaunchLibraryAPIHandler.handleLaunchLibraryData() -> Unable to format endDate \(windowend)")
                break
            }
            
            // Format status string
            var statusString: String
            switch status {
            case 1:
                statusString = "Green"
            case 2:
                statusString = "Red"
            case 3:
                statusString = "Success"
            default: // 0
                statusString = "Failed"
            }
            
            // Guard location name string
            guard   let launchFrom = launch["location"] as? [String:AnyObject],
                    let location = launchFrom["name"] as? String else {
                let APIHandlerError = NSError(domain: Config.domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process launch location: \(id)"])
                print(APIHandlerError)
                continue
            }
            
            // Guard video URL string for NULL
            var watchStr : String
            if let str = launch["videoURLs"] as? String {
                // Pass URL
                watchStr = str
            } else {
                // URL not available
                watchStr = ""
            }
            
            //
            // TODO: Process rocket info asynchronously
            //
            //
            guard   let rocketObj = launch["rocket"] as? [String:AnyObject],
                let rocketID = rocketObj["id"] as? Int,
                let rocketName = rocketObj["name"] as? String,
                let agenices = rocketObj["agencies"] as? Array<[String:AnyObject]>,
                let imageStr = rocketObj["imageURL"] as? String else {
                    
                    let APIHandlerError = NSError(domain: Config.domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey: "Un-able to process rocket information for lauch: \(id)"])
                    print(APIHandlerError)
                    continue
            }
            
            // Create Rocket object
            let rocket = Rocket(id: rocketID, name: rocketName, agencies: agenices, imageString: imageStr)
            //
            //
            //
            //
            
            // Create Rocket Launch object
            let rocketLaunch = RocketLaunch(id: id, name: name, status: statusString, date: date, launchWindow: [startDate,endDate], launchFrom: location, whereToWatch: watchStr, rocket: rocket)
            
            // Store Rocket Launch in Library (RocketLaunches collection)
            launchLibrary.append(rocketLaunch)
            
        }
        
//        OperationQueue.main.addOperation({
        completion(launchLibrary, nil)
//        })
    }
    
    func handleLaunchLibrary(launches: [[String: AnyObject]], completion: @escaping (_ results: [RocketLaunch]?, _ error: NSError?) -> Void) {
        var rocketLaunches = [RocketLaunch]()
        // Data Structure is not set up perfectly so we must use a handler
        let rocketLaunch = RocketLaunch()
        for launch in launches {
            rocketLaunch.setValuesForKeys(launch)
            rocketLaunches.append(rocketLaunch)
        }
        completion(rocketLaunches, nil)
    }
    
    let ignoreKeys: Array = ["netstamp","failreason","probability","inhold","lsp","tbddate","isonet","vidURLs","missions","infoURL","net","infoURLs","isostart","vidURL","wsstamp","holdreason","hashtag","westamp","tbdtime"]
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "rocket" {
            for dict in value as! [[String:AnyObject]]{
                let rocket = Rocket()
                rocket.setValuesForKeys(dict)
            }
        } else if ignoreKeys.contains(key) {
            // Ignore known fields
            
        } else {
            super.setValue(value, forKey: key)
        }
    }
}


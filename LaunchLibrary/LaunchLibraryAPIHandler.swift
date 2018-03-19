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
            
            // Guard launch properties required for collection
            guard   let id = launch["id"] as? Int,
                let name = launch["name"] as? String,
                let net  = launch["net"]  as? String, // (formatted as Month, dd, yyyy hh24:mi:ss UTC)
                let status = launch["status"] as? Bool,
                let windSrt = launch["windowstart"] as? String,
                let windEnd = launch["windowend"] as? String,
                let launchFrom = launch["location"] as? [String:AnyObject], // ["name"]
                let rocketObj = launch["rocket"] as? [String:AnyObject] // We will process this in a seperate VC
                else {
                    let APIHandlerError:NSError!
                    if let id = launch["id"] as? Int {
                        APIHandlerError = NSError(domain: Config.domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process launch: \(id)"])
                    } else {
                        APIHandlerError = NSError(domain: Config.domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process launch"])
                    }
                    print(APIHandlerError)
                    continue
            }
            
            // January 25, 2018 05:51:00 UTC
            
//            // Guard date formatter
//            let dateFormatterGet = DateFormatter()
//            dateFormatterGet.dateFormat = "MMMM dd, yy hh:mm:ss"
//
//            guard let date = dateFormatterGet.date(from: net) else {
//                // Problem formatting date
//                break
//            }
//
//            guard let startDate = dateFormatterGet.date(from: windSrt) else {
//                // Problem formatting start date
//                break
//            }
//
//            guard let endDate = dateFormatterGet.date(from: windEnd) else {
//                // Problem formatting end date
//                break
//            }
            
            
            // Guard location name string
            guard let location = launchFrom["name"] as? String else {
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
            guard   let rocketID = rocketObj["id"] as? Int,
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
            let rocketLaunch = RocketLaunch(id: id, name: name, status: status, date: net, launchWindow: [windSrt,windEnd], launchFrom: location, whereToWatch: watchStr, rocket: rocket)
            
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


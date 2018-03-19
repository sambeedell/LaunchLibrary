//
//  LaunchLibraryAPI.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

let domain = "Dev.LaunchLibrary"

class LaunchLibraryAPI {
    
    let processingQueue = OperationQueue()
    
    func searchLibraryForLaunch(amount : Int, completion : @escaping (_ results: RocketLaunches?, _ error : NSError?) -> Void){
        
        // https://launchlibrary.net/1.3/launch?next=5
        
        let URLString = "https://launchlibrary.net/1.3/launch?mode=verbose&next=\(amount)"
        
        guard let searchURL = URL(string:URLString) else {
            let APIError = NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"URL not valid: \(URLString)"])
            completion(nil, APIError)
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Cannot create shared data task"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response: \(searchURL)"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    // TODO: Restart search 
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject] else {
                    
                    let APIError = NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unable to deserialise JSON"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                if (resultsDictionary["status"] as? String) != nil {
                    let APIError = NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Incorrect API call, check URL: \(resultsDictionary["msg"])"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                guard let launches = resultsDictionary["launches"] as? [[String: AnyObject]] else {
                    
                    let APIError = NSError(domain: domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Invalid API response format"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }

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
                            let APIError:NSError!
                            if let id = launch["id"] as? Int {
                                APIError = NSError(domain: domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process launch: \(id)"])
                            } else {
                                APIError = NSError(domain: domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process launch"])
                            }
                            print(APIError)
                            continue
                    }
                    
                    // January 25, 2018 05:51:00 UTC
                    
//                    // Guard date formatter
//                    let dateFormatterGet = DateFormatter()
//                    dateFormatterGet.dateFormat = "MMMM dd, yy hh:mm:ss"
//                    
//                    guard let date = dateFormatterGet.date(from: net) else {
//                        // Problem formatting date
//                        break
//                    }
//                    
//                    guard let startDate = dateFormatterGet.date(from: windSrt) else {
//                        // Problem formatting start date
//                        break
//                    }
//                    
//                    guard let endDate = dateFormatterGet.date(from: windEnd) else {
//                        // Problem formatting end date
//                        break
//                    }
                    
                    
                    // Guard location name string
                    guard let location = launchFrom["name"] as? String else {
                        let APIError = NSError(domain: domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process launch location: \(id)"])
                        print(APIError)
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
                    
                    // Process rocket info
                    guard   let rocketID = rocketObj["id"] as? Int,
                            let rocketName = rocketObj["name"] as? String,
                            let agenices = rocketObj["agencies"] as? Array<[String:AnyObject]>,
                            let imageStr = rocketObj["imageURL"] as? String else {
                                
                                let APIError = NSError(domain: domain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Un-able to process rocket information for lauch: \(id)"])
                                print(APIError)
                                continue
                    }
                    
                    
                    // Create Rocket object
                    let rocket = Rocket(id: rocketID, name: rocketName, agencies: agenices, imageString: imageStr)
                    
                    // Create Rocket Launch object
                    let rocketLaunch = RocketLaunch(id: id, name: name, status: status, date: net, launchWindow: [windSrt,windEnd], launchFrom: location, whereToWatch: watchStr, rocket: rocket)
                    
                    // Store Rocket Launch in Library (RocketLaunches collection)
                    launchLibrary.append(rocketLaunch)

                }
                
                OperationQueue.main.addOperation({
                    completion(RocketLaunches(collection: launchLibrary), nil)
                })
                
            } catch _ {
                completion(nil, nil)
                return
            }
            
            
        }) .resume()
    }
}


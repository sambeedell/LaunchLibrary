//
//  LaunchLibraryAPI.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

class LaunchLibraryAPI {
    
    let processingQueue = OperationQueue()
    
    func searchLibraryForLaunch(amount : Int, completion : @escaping (_ results: [[String: AnyObject]]?, _ error : NSError?) -> Void){
        
        // mode=verbose & next=50
        
        let URLString = Config.baseURL + "?mode=verbose&next=\(amount)"
        
        guard let searchURL = URL(string:URLString) else {
            let APIError = NSError(domain: Config.domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"URL not valid: \(URLString)"])
            completion(nil, APIError)
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: searchURL), completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: Config.domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Cannot create shared data task"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: Config.domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response: \(searchURL)"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    // TODO: Restart search 
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject] else {
                    
                    let APIError = NSError(domain: Config.domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unable to deserialise JSON"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                if (resultsDictionary["status"] as? String) != nil {
                    let APIError = NSError(domain: Config.domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Incorrect API call, check URL: \(resultsDictionary["msg"])"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                guard let launches = resultsDictionary["launches"] as? [[String: AnyObject]] else {
                    
                    let APIError = NSError(domain: Config.domain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Invalid API response format"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                OperationQueue.main.addOperation({
                    completion(launches, nil)
                })
                
            } catch _ {
                completion(nil, nil)
                return
            }
            
            
        }).resume()
    }

}


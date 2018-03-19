//
//  NetworkService.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 16/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Foundation

struct NetworkService {
    
    static let sharedInstance = NetworkService()
    
    func fetchRocketLaunches(amount: Int, completionHandler: @escaping ([RocketLaunch]?) -> ()){
        // TODO: Use TRON or Alamofire for API calls
        let api = LaunchLibraryAPI()
        api.searchLibraryForLaunch(amount: amount, completion: {data, error in
            if let error = error {
                print(error)
                return
            }
            if let data = data {
                LaunchLibraryAPIHandler().handleLaunchLibraryData(launches: data, completion: { (rocketLaunches, error) in
                    if let error = error {
                        print(error)
                    }
                    if let rocketLaunches = rocketLaunches {
                        completionHandler(rocketLaunches)
                    } else {
                        completionHandler(nil)
                    }
                })
            }
        })
    }
    
    func fetchRocketImage(imageURL: URL, completionHandler: @escaping (Data?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData = try? Data(contentsOf: imageURL){
                completionHandler(imageData)
            } else {
                completionHandler(nil)
            }
        }
    }
}
